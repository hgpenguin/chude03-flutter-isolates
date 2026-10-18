import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/models/benchmark_report.dart';
import 'package:isolate_demo/models/frame_stats.dart';
import 'package:isolate_demo/models/parse_summary.dart';
import 'package:isolate_demo/models/run_record.dart';
import 'package:isolate_demo/models/task_result.dart';
import 'package:isolate_demo/services/report_writer.dart';

void main() {
  test(
    'writes typed records as compatible JSON/CSV and escapes errors',
    () async {
      final temp = await Directory.systemTemp.createTemp(
        'isolate-report-test-',
      );
      addTearDown(() => temp.delete(recursive: true));
      final sourceTimestamps = [10000, 20000];
      final record = RunRecord(
        runId: 1,
        utc: DateTime.utc(2026, 10, 17),
        mode: ProcessingMode.spawn,
        task: const TaskResult(
          ParseSummary(count: 2, totalAmount: 130),
          10,
          20,
        ),
        taskStartUs: 1000,
        taskEndUs: 21000,
        frames: const FrameStats(
          windowMs: 5000,
          frameCallbacks: 2,
          estimatedUiFps: 0.4,
          maxGapMs: 4980,
        ),
        incomplete: true,
        lifecycleAtStart: 'unknown',
        lifecycleAtEnd: 'unknown',
        error: 'lỗi "a", b\ndòng 2',
        frameTimestampsUs: sourceTimestamps,
      );
      sourceTimestamps.clear();
      final runs = [record];
      final report = BenchmarkReport(
        environment: ReportEnvironment.capture(60),
        dataset: null,
        runs: runs,
      );
      runs.clear();
      final writer = ReportWriter(directory: temp);
      final saved = await writer.save(report);
      final json = jsonDecode(await File(saved.jsonPath).readAsString()) as Map;
      final row = (json['runs'] as List).single as Map;
      expect(row['count'], 2);
      expect(row['totalAmount'], 130);
      expect(row['mode'], 'spawn');
      expect(row['estimatedUiFps'], 0.4);
      expect(row['frameTimestampsUs'], [10000, 20000]);
      expect(
        await File(saved.csvPath).readAsString(),
        contains('"lỗi ""a"", b\ndòng 2"'),
      );
      final another = await writer.save(report);
      expect(another.jsonPath, isNot(saved.jsonPath));
      expect(await File(saved.jsonPath).exists(), isTrue);
    },
  );

  test('unwritable output propagates a file error', () async {
    final temp = await Directory.systemTemp.createTemp('isolate-report-error-');
    addTearDown(() => temp.delete(recursive: true));
    final file = await File('${temp.path}/not-a-directory').writeAsString('x');
    final writer = ReportWriter(directory: Directory(file.path));
    await expectLater(
      writer.save(
        BenchmarkReport(
          environment: ReportEnvironment.capture(null),
          dataset: null,
          runs: [],
        ),
      ),
      throwsA(isA<FileSystemException>()),
    );
  });
}
