import 'parse_summary.dart';

enum ProcessingMode {
  main('Main Isolate'),
  compute('compute'),
  spawn('Isolate.spawn');

  const ProcessingMode(this.label);
  final String label;
}

class ParseResult {
  const ParseResult(this.summary, this.parseUs);
  final ParseSummary summary;
  final int parseUs;
}

class TaskResult {
  const TaskResult(this.summary, this.parseMs, this.elapsedMs);
  final ParseSummary summary;
  final double parseMs;
  final double elapsedMs;
}
