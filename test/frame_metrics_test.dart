import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/services/frame_metrics.dart';

void main() {
  test('FPS denominator includes one second with no UI callbacks', () {
    final metrics = FrameMetrics();
    for (var ms = 10; ms <= 5000; ms += 10) {
      if (ms > 1000 && ms < 2000) continue;
      metrics.record(ms * 1000);
    }
    final result = metrics.finish(5000000);
    expect(result.windowMs, 5000);
    expect(result.maxGapMs, 1000);
    expect(result.estimatedUiFps, closeTo(80.2, 0.001));
  });

  test('both boundary gaps and completely empty window are counted', () {
    final metrics = FrameMetrics()
      ..record(2000000)
      ..record(2100000);
    expect(metrics.finish(5000000).maxGapMs, 2900);
    final empty = FrameMetrics().finish(5000000);
    expect(empty.maxGapMs, 5000);
    expect(empty.estimatedUiFps, 0);
  });
}
