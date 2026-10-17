import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../models/run_record.dart';
import '../models/task_result.dart';
import '../models/benchmark_report.dart';
import '../services/dataset.dart';
import '../services/frame_metrics.dart';
import '../services/processing.dart';
import '../services/report_writer.dart';

bool isKnownBackground(AppLifecycleState? state) =>
    state != null && state != AppLifecycleState.resumed;

class BenchmarkController extends ChangeNotifier with WidgetsBindingObserver {
  BenchmarkController({
    this.loadDataset = Dataset.load,
    ReportWriter? reportWriter,
  }) : _writer = reportWriter ?? ReportWriter() {
    WidgetsBinding.instance.addObserver(this);
  }

  final Future<Dataset> Function() loadDataset;
  final ReportWriter _writer;
  final _closed = Completer<void>();
  final List<RunRecord> _runs = [];
  Dataset? _dataset;
  SpawnJob? _job;
  FrameMetrics? _frames;
  Stopwatch? _window;
  bool _disposed = false;
  bool _busy = false;
  bool _loading = false;
  bool _interrupted = false;
  double? _progress;
  String _status = 'Chưa nạp dữ liệu';
  String _detail = 'Nạp JSON trước, sau đó chọn chế độ xử lý.';
  String? _savedPath;
  double? displayRefreshRateHz;

  Dataset? get dataset => _dataset;
  List<RunRecord> get runs => List.unmodifiable(_runs);
  bool get busy => _busy;
  bool get loading => _loading;
  bool get ready => !_disposed && !_busy && !_loading && _dataset != null;
  String get status => _status;
  String get detail => _detail;
  String? get savedPath => _savedPath;

  /// Tiến độ 0..1 của Isolate.spawn đang chạy; null khi không có worker.
  double? get progress => _progress;
  bool get canCancel => !_disposed && _job != null;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void _update(void Function() change) {
    if (!_disposed) {
      change();
      _changed();
    }
  }

  void recordFrame() {
    final watch = _window;
    if (watch != null) _frames?.record(watch.elapsedMicroseconds);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_busy && isKnownBackground(state)) _interrupted = true;
  }

  Future<void> _wait(Duration duration) async {
    await Future.any([Future<void>.delayed(duration), _closed.future]);
    if (_disposed) throw WorkerCancelled();
  }

  Future<void> load() async {
    if (_disposed || _busy || _loading) return;

    _loading = true;
    _dataset = null;
    _runs.clear();
    _savedPath = null;
    _status = 'Đang nạp dữ liệu';
    _changed();
    try {
      final dataset = await loadDataset();
      if (_disposed) return;

      _dataset = dataset;
      _status = 'Sẵn sàng';
      _detail = 'Đã kiểm tra byte UTF-8 và checksum. Nạp nằm ngoài phép đo.';
      _changed();
    } catch (error) {
      if (!_disposed) {
        _status = 'Lỗi';
        _detail = 'Không nạp được dataset: $error';
        _changed();
      }
    } finally {
      if (!_disposed) _update(() => _loading = false);
    }
  }

  Future<TaskResult> _process(ProcessingMode mode, String text) async {
    final job = mode == ProcessingMode.spawn
        ? SpawnJob(onProgress: (value) => _update(() => _progress = value))
        : null;
    _update(() {
      _job = job;
      _progress = job == null ? null : 0;
    });
    try {
      return await processJson(mode, text, spawnJob: job);
    } finally {
      _update(() {
        _job = null;
        _progress = null;
      });
    }
  }

  /// Nút Hủy: kill worker ngay; mẫu đo đang chạy được ghi là chưa đủ.
  void cancelRun() => _job?.cancel();

  Future<void> _sample(ProcessingMode? mode) async {
    final dataset = _dataset!;
    final lifecycleAtStart = WidgetsBinding.instance.lifecycleState;
    _interrupted = isKnownBackground(lifecycleAtStart);

    _status = 'Đang chạy • ${mode?.label ?? 'Không tải'}';
    _detail =
        'Cửa sổ mục tiêu 5 giây, gồm thời gian trước và sau tác vụ. '
        'Thử bấm nút + và quan sát vòng quay.';
    _changed();
    await WidgetsBinding.instance.endOfFrame;
    if (_disposed) throw WorkerCancelled();
    final frames = FrameMetrics();
    final window = Stopwatch()..start();
    _frames = frames;
    _window = window;
    TaskResult? result;
    Object? failure;
    var taskStartUs = 0;
    var taskEndUs = 0;
    try {
      await _wait(const Duration(seconds: 1));
      taskStartUs = window.elapsedMicroseconds;
      if (mode != null) {
        try {
          result = await _process(mode, dataset.text);
          dataset.verify(result.summary);
        } finally {
          taskEndUs = window.elapsedMicroseconds;
        }
      } else {
        taskEndUs = window.elapsedMicroseconds;
      }
      final remainingUs = math.max(
        1000000,
        5000000 - window.elapsedMicroseconds,
      );
      await _wait(Duration(microseconds: remainingUs));
    } catch (error) {
      failure = error;
    } finally {
      window.stop();
      _window = null;
      _frames = null;
    }
    if (_disposed) throw WorkerCancelled();
    final row = RunRecord(
      runId: _runs.length + 1,
      utc: DateTime.now().toUtc(),
      mode: mode,
      task: result,
      taskStartUs: taskStartUs,
      taskEndUs: taskEndUs,
      frames: frames.finish(window.elapsedMicroseconds),
      incomplete:
          _interrupted || failure != null || frames.timestampsUs.isEmpty,
      lifecycleAtStart: lifecycleAtStart?.name ?? 'unknown',
      lifecycleAtEnd: WidgetsBinding.instance.lifecycleState?.name ?? 'unknown',
      error: failure?.toString(),
      frameTimestampsUs: frames.timestampsUs,
    );
    _update(() => _runs.add(row));
    if (failure != null) throw failure;
  }

  Future<void> execute({
    ProcessingMode? mode,
    bool batch = false,
    bool invalid = false,
  }) async {
    if (!ready) return;
    _update(() => _busy = true);
    try {
      if (invalid) {
        _update(() => _status = 'Đang thử JSON lỗi');
        await _process(ProcessingMode.spawn, '[{"amount":"sai kiểu"}]');
        throw StateError('Parser đã chấp nhận dữ liệu sai!');
      } else if (batch) {
        // Warm-up cả ba chế độ, không ghi vào mẫu chính thức.
        for (final warmupMode in ProcessingMode.values) {
          if (_disposed) throw WorkerCancelled();
          _update(() => _status = 'Warm-up • ${warmupMode.label}');
          await WidgetsBinding.instance.endOfFrame;
          if (_disposed) throw WorkerCancelled();
          final result = await _process(warmupMode, _dataset!.text);
          _dataset!.verify(result.summary);
        }
        await _sample(null);
        for (var round = 0; round < 5; round++) {
          for (var offset = 0; offset < 3; offset++) {
            await _sample(ProcessingMode.values[(round + offset) % 3]);
          }
        }
      } else {
        await _sample(mode);
      }
      if (_disposed) return;

      _status = 'Thành công';
      _detail =
          'Kết quả đã đối chiếu metadata. '
          'UI FPS là số callback UI/giây thực tế; không phải FPS màn hình vật lý.';
      _changed();
    } catch (error) {
      if (!_disposed) {
        if (error is WorkerCancelled) {
          _status = 'Đã hủy';
          _detail = 'Worker đã bị kill giữa chừng; mẫu đo ghi là chưa đủ.';
        } else {
          _status = invalid && error is FormatException
              ? 'Đã bắt lỗi dữ liệu đúng dự kiến'
              : 'Lỗi';
          _detail = '$error';
        }
        _changed();
      }
    } finally {
      if (!_disposed) {
        // Ghi file sau cửa sổ đo, kể cả batch có lỗi để giữ mẫu dở dang.
        try {
          if (_runs.isNotEmpty) await _save();
        } catch (error) {
          if (!_disposed) {
            _status = 'Lỗi lưu báo cáo';
            _detail = '$error';
            _changed();
          }
        }
        if (!_disposed) _update(() => _busy = false);
      }
    }
  }

  BenchmarkReport report() => BenchmarkReport(
    environment: ReportEnvironment.capture(displayRefreshRateHz),
    dataset: _dataset?.metadata,
    runs: _runs,
  );

  String reportJson() => report().encode();

  Future<void> _save() async {
    final saved = await _writer.save(report());
    if (!_disposed) _update(() => _savedPath = saved.jsonPath);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _closed.complete();
    _job?.cancel();
    super.dispose();
  }
}
