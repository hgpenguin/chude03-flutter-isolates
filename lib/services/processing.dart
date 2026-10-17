import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import 'json_parser.dart';

import '../models/task_result.dart';
import '../models/worker_message.dart';

// Callback top-level: không capture State, widget hoặc BuildContext.
ParseResult parseTimed(String text, {ProgressCallback? onProgress}) {
  final watch = Stopwatch()..start();
  final summary = parseAndSummarize(text, onProgress: onProgress);
  watch.stop();
  return ParseResult(summary, watch.elapsedMicroseconds);
}

// Sealed messages chỉ chứa dữ liệu gửi được, không giữ State/BuildContext.
void jsonWorker(WorkerRequest request) {
  sendWorkerResult(
    request,
    (text) => parseTimed(
      text,
      onProgress: (done, total) =>
          request.reply.send(WorkerProgress(done, total)),
    ),
  );
}

void sendWorkerResult(
  WorkerRequest request,
  ParseResult Function(String) parse,
) {
  try {
    request.reply.send(WorkerSuccess(parse(request.text)));
  } on FormatException catch (error, stack) {
    request.reply.send(WorkerDataError(error.message, '$stack', error.offset));
  } catch (error, stack) {
    request.reply.send(
      WorkerFailure(error.runtimeType.toString(), '$error', '$stack'),
    );
  }
}

class WorkerCancelled implements Exception {
  @override
  String toString() => 'Worker đã được đóng.';
}

// Cùng một port nhận progress/result/error/exit để giữ thứ tự message của worker.
class SpawnJob {
  SpawnJob({
    this.timeout = const Duration(seconds: 60),
    this.entryPoint = jsonWorker,
    this.onProgress,
  });

  final Duration timeout;
  final void Function(WorkerRequest) entryPoint;
  final void Function(double fraction)? onProgress;
  final _done = Completer<ParseResult>();
  ReceivePort? _port;
  StreamSubscription<dynamic>? _subscription;
  Timer? _timer;
  Isolate? _worker;
  bool _started = false;
  bool _closed = false;

  Future<ParseResult> run(String text) async {
    if (_started || _closed) throw StateError('Job chỉ chạy một lần.');
    _started = true;
    final port = _port = ReceivePort();
    _subscription = port.listen((dynamic message) {
      if (_done.isCompleted) return;
      if (message is WorkerMessage) {
        switch (message) {
          case WorkerProgress(:final fraction):
            onProgress?.call(fraction);
          case WorkerSuccess(:final result):
            _done.complete(result);
          case WorkerDataError(:final message, :final stack, :final offset):
            _done.completeError(
              FormatException(message, null, offset),
              StackTrace.fromString(stack),
            );
          case WorkerFailure(:final errorType, :final message, :final stack):
            _done.completeError(
              RemoteWorkerException(errorType, message),
              StackTrace.fromString(stack),
            );
        }
      } else if (message is List && message.length == 2) {
        // onError của VM chỉ gửi chuỗi lỗi + stack; không đoán kiểu ngoại lệ.
        _done.completeError(
          RemoteWorkerException('uncaught', '${message[0]}'),
          StackTrace.fromString('${message[1]}'),
        );
      } else if (message == null) {
        _done.completeError(StateError('Worker thoát không trả kết quả.'));
      } else {
        _done.completeError(StateError('Worker gửi message không hợp lệ.'));
      }
    });
    _timer = Timer(timeout, () {
      if (!_done.isCompleted) {
        _done.completeError(TimeoutException('Worker quá thời gian.', timeout));
      }
    });
    // Gắn handler trước khi spawn: timeout/dispose có thể đến lúc đang spawn.
    unawaited(_launch(text, port.sendPort));
    try {
      return await _done.future;
    } finally {
      _cleanup();
    }
  }

  Future<void> _launch(String text, SendPort reply) async {
    try {
      final worker = await Isolate.spawn(
        entryPoint,
        WorkerRequest(text, reply),
        onError: reply,
        onExit: reply,
        errorsAreFatal: true,
        debugName: 'json-ports-worker',
      );
      if (_closed) {
        worker.kill(priority: Isolate.immediate);
      } else {
        _worker = worker;
      }
    } catch (error, stack) {
      if (!_done.isCompleted) _done.completeError(error, stack);
    }
  }

  void cancel() {
    if (_started && !_done.isCompleted) {
      _done.completeError(WorkerCancelled());
    }
    _cleanup();
  }

  void _cleanup() {
    _closed = true;
    _timer?.cancel();
    _worker?.kill(priority: Isolate.immediate);
    unawaited(_subscription?.cancel());
    _port?.close();
  }
}

Future<TaskResult> processJson(
  ProcessingMode mode,
  String text, {
  SpawnJob? spawnJob,
}) async {
  final watch = Stopwatch()..start();
  final ParseResult message;
  switch (mode) {
    case ProcessingMode.main:
      message = parseTimed(text);
    case ProcessingMode.compute:
      message = await compute(parseTimed, text, debugLabel: 'json-compute');
    case ProcessingMode.spawn:
      message = await (spawnJob ?? SpawnJob()).run(text);
  }
  watch.stop();
  return TaskResult(
    message.summary,
    message.parseUs / 1000,
    watch.elapsedMicroseconds / 1000,
  );
}
