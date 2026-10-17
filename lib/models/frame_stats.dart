class FrameStats {
  const FrameStats({
    required this.windowMs,
    required this.frameCallbacks,
    required this.estimatedUiFps,
    required this.maxGapMs,
  });
  final double windowMs;
  final int frameCallbacks;
  final double estimatedUiFps;
  final double maxGapMs;
}
