import 'frame_stats.dart';
import 'task_result.dart';

class RunRecord {
  RunRecord({
    required this.runId,
    required this.utc,
    required this.mode,
    required this.task,
    required this.taskStartUs,
    required this.taskEndUs,
    required this.frames,
    required this.incomplete,
    required this.lifecycleAtStart,
    required this.lifecycleAtEnd,
    this.error,
    required List<int> frameTimestampsUs,
  }) : frameTimestampsUs = List.unmodifiable(frameTimestampsUs);

  final int runId;
  final DateTime utc;
  final ProcessingMode mode;
  final TaskResult? task;
  final int taskStartUs;
  final int taskEndUs;
  final FrameStats frames;
  final bool incomplete;
  final String lifecycleAtStart;
  final String lifecycleAtEnd;
  final String? error;
  final List<int> frameTimestampsUs;

  Map<String, Object?> toJson() => {
    'runId': runId,
    'utc': utc.toUtc().toIso8601String(),
    'mode': mode.name,
    'taskMs': task?.elapsedMs,
    'parseMs': task?.parseMs,
    'taskStartUs': taskStartUs,
    'taskEndUs': taskEndUs,
    'windowMs': frames.windowMs,
    'frameCallbacks': frames.frameCallbacks,
    'estimatedUiFps': frames.estimatedUiFps,
    'maxGapMs': frames.maxGapMs,
    'count': task?.summary.count,
    'totalAmount': task?.summary.totalAmount,
    'incomplete': incomplete,
    'lifecycleAtStart': lifecycleAtStart,
    'lifecycleAtEnd': lifecycleAtEnd,
    'error': error,
    'frameTimestampsUs': frameTimestampsUs,
  };
}
