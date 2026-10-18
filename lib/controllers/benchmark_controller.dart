import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../models/benchmark_report.dart';
import '../models/run_record.dart';
import '../models/task_result.dart';
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
  double? displayRefreshRateHz;

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

  void _update(void Function() change) {
    if (_disposed) return;
    change();
    notifyListeners();
  }

  void _setStatus(String status, [String? detail]) => _update(() {
    _status = status;
    if (detail != null) _detail = detail;
  });

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

    _update(() {
      _loading = true;
      _dataset = null;
      _runs.clear();
      _savedPath = null;
      _status = 'Đang nạp dữ liệu';
    });
    try {
      final dataset = await loadDataset();
      if (_disposed) return;
      _dataset = dataset;
      _setStatus(
        'Sẵn sàng',
        'Đã kiểm tra byte UTF-8 và checksum. Nạp nằm ngoài phép đo.',
      );
    } catch (error) {
      _setStatus('Lỗi', 'Không nạp được dataset: $error');
    } finally {
      _update(() => _loading = false);
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

  Future<void> _sample(ProcessingMode mode) async {
    final dataset = _dataset!;
    final lifecycleAtStart = WidgetsBinding.instance.lifecycleState;
    _interrupted = isKnownBackground(lifecycleAtStart);

    _setStatus(
      'Đang chạy • ${mode.label}',
      'Cửa sổ mục tiêu 5 giây, gồm thời gian trước và sau tác vụ. '
          'Thử bấm nút + và quan sát vòng quay.',
    );
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
      try {
        result = await _process(mode, dataset.text);
        dataset.verify(result.summary);
      } finally {
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

  Future<void> execute(ProcessingMode mode) => _runExclusive(() async {
    await _sample(mode);
    _setStatus(
      'Thành công',
      'Kết quả đã đối chiếu metadata. '
          'UI FPS là số callback UI/giây thực tế; không phải FPS màn hình vật lý.',
    );
  });

  Future<void> tryInvalidJson() => _runExclusive(() async {
    _setStatus('Đang thử JSON lỗi');
    try {
      await _process(ProcessingMode.spawn, '[{"amount":"sai kiểu"}]');
    } on FormatException catch (error) {
      _setStatus('Đã bắt lỗi dữ liệu đúng dự kiến', '$error');
      return;
    }
    throw StateError('Parser đã chấp nhận dữ liệu sai.');
  });

  Future<void> _runExclusive(Future<void> Function() task) async {
    if (!ready) return;
    _update(() => _busy = true);
    final runsBefore = _runs.length;
    try {
      await task();
    } on WorkerCancelled {
      _setStatus(
        'Đã hủy',
        'Worker đã bị kill giữa chừng; mẫu đo ghi là chưa đủ.',
      );
    } catch (error) {
      _setStatus('Lỗi', '$error');
    }
    if (_disposed) return;

    // Lưu cả mẫu lỗi để không mất dữ liệu của lần đo dở dang.
    if (_runs.length != runsBefore) {
      try {
        final saved = await _writer.save(report());
        _update(() => _savedPath = saved.jsonPath);
      } catch (error) {
        _setStatus('Lỗi lưu báo cáo', '$error');
      }
    }
    _update(() => _busy = false);
  }

  BenchmarkReport report() => BenchmarkReport(
    environment: ReportEnvironment.capture(displayRefreshRateHz),
    dataset: _dataset?.metadata,
    runs: _runs,
  );

  String reportJson() => report().encode();

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
