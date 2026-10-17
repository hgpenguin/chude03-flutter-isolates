import 'dart:isolate';

import 'task_result.dart';

class WorkerRequest {
  const WorkerRequest(this.text, this.reply);
  final String text;
  final SendPort reply;
}

sealed class WorkerMessage {
  const WorkerMessage();
}

// Worker gửi nhiều lần trong lúc kiểm tra bản ghi, trước WorkerSuccess.
final class WorkerProgress extends WorkerMessage {
  const WorkerProgress(this.done, this.total);
  final int done;
  final int total;
  double get fraction => total == 0 ? 1 : done / total;
}

final class WorkerSuccess extends WorkerMessage {
  const WorkerSuccess(this.result);
  final ParseResult result;
}

final class WorkerDataError extends WorkerMessage {
  const WorkerDataError(this.message, this.stack, this.offset);
  final String message;
  final String stack;
  final int? offset;
}

final class WorkerFailure extends WorkerMessage {
  const WorkerFailure(this.errorType, this.message, this.stack);
  final String errorType;
  final String message;
  final String stack;
}

class RemoteWorkerException implements Exception {
  const RemoteWorkerException(this.errorType, this.message);
  final String errorType;
  final String message;

  @override
  String toString() => 'Worker $errorType: $message';
}
