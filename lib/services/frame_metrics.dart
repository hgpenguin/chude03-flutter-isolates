import 'dart:math' as math;

import '../models/frame_stats.dart';

// Timestamp từ cùng Stopwatch, bao gồm cả hai biên cửa sổ.
class FrameMetrics {
  final List<int> timestampsUs = [];

  void record(int microseconds) => timestampsUs.add(microseconds);

  FrameStats finish(int endUs) {
    var previous = 0;
    var maxGap = 0;
    var count = 0;
    for (final timestamp in timestampsUs) {
      if (timestamp < 0 || timestamp > endUs) continue;
      maxGap = math.max(maxGap, timestamp - previous);
      previous = timestamp;
      count++;
    }
    maxGap = math.max(maxGap, endUs - previous);
    return FrameStats(
      windowMs: endUs / 1000,
      frameCallbacks: count,
      estimatedUiFps: endUs > 0
          ? count * Duration.microsecondsPerSecond / endUs
          : 0,
      maxGapMs: maxGap / 1000,
    );
  }
}
