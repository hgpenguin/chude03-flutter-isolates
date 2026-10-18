import 'dart:io';

import '../models/benchmark_report.dart';

class SavedReport {
  const SavedReport(this.jsonPath, this.csvPath);
  final String jsonPath;
  final String csvPath;
}

class ReportWriter {
  ReportWriter({Directory? directory})
    : directory = directory ?? _defaultDirectory();

  final Directory directory;

  static Directory _defaultDirectory() {
    const output = String.fromEnvironment('BENCHMARK_OUTPUT');
    return Directory(
      output.isEmpty ? '${Directory.current.path}/benchmark_results' : output,
    );
  }

  Future<SavedReport> save(BenchmarkReport report) async {
    await directory.create(recursive: true);
    final bundle = await directory.createTemp('runs-');
    final json = File('${bundle.path}/report.json');
    final csv = File('${bundle.path}/report.csv');
    await json.writeAsString(report.encode());
    await csv.writeAsString(toCsv(report));
    return SavedReport(json.path, csv.path);
  }

  String toCsv(BenchmarkReport report) {
    const header =
        'runId,utc,mode,taskMs,parseMs,windowMs,frameCallbacks,'
        'estimatedUiFps,maxGapMs,count,totalAmount,incomplete,error';
    String cell(Object? value) =>
        '"${(value ?? '').toString().replaceAll('"', '""')}"';
    final lines = report.runs.map(
      (r) => <Object?>[
        r.runId,
        r.utc.toUtc().toIso8601String(),
        r.modeName,
        r.task?.elapsedMs,
        r.task?.parseMs,
        r.frames.windowMs,
        r.frames.frameCallbacks,
        r.frames.estimatedUiFps,
        r.frames.maxGapMs,
        r.task?.summary.count,
        r.task?.summary.totalAmount,
        r.incomplete,
        r.error,
      ].map(cell).join(','),
    );
    return '$header\n${lines.join('\n')}\n';
  }
}
