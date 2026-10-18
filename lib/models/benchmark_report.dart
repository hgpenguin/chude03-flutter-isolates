import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'dataset_metadata.dart';
import 'run_record.dart';

class ReportEnvironment {
  const ReportEnvironment({
    required this.os,
    required this.processors,
    required this.dart,
    required this.flutter,
    required this.buildMode,
    required this.displayRefreshRateHz,
    required this.cpuRamAndConditions,
  });
  final String os;
  final int processors;
  final String dart;
  final String flutter;
  final String buildMode;
  final double? displayRefreshRateHz;
  final String cpuRamAndConditions;

  factory ReportEnvironment.capture(double? refreshRate) => ReportEnvironment(
    os: Platform.operatingSystemVersion,
    processors: Platform.numberOfProcessors,
    dart: Platform.version,
    flutter: const String.fromEnvironment(
      'FLUTTER_VERSION',
      defaultValue: 'chưa ghi',
    ),
    buildMode: kProfileMode ? 'profile' : (kReleaseMode ? 'release' : 'debug'),
    displayRefreshRateHz: refreshRate,
    cpuRamAndConditions: const String.fromEnvironment(
      'BENCHMARK_MACHINE',
      defaultValue: 'chưa ghi',
    ),
  );

  Map<String, Object?> toJson() => {
    'os': os,
    'processors': processors,
    'dart': dart,
    'flutter': flutter,
    'buildMode': buildMode,
    'displayRefreshRateHz': displayRefreshRateHz,
    'cpuRamAndConditions': cpuRamAndConditions,
  };
}

class BenchmarkReport {
  BenchmarkReport({
    required this.environment,
    required this.dataset,
    required List<RunRecord> runs,
  }) : runs = List.unmodifiable(runs);
  final ReportEnvironment environment;
  final DatasetMetadata? dataset;
  final List<RunRecord> runs;

  Map<String, Object?> toJson() => {
    'schema': 1,
    'environment': environment.toJson(),
    'dataset': dataset?.toJson(),
    'method':
        'Đếm callback của AnimationController trong cửa sổ đo bằng Stopwatch. '
        'Cửa sổ mục tiêu 5 giây: tác vụ bắt đầu sau 1 giây, sau tác vụ chờ ít nhất 1 giây; '
        'tính cả hai khoảng biên. Mỗi lần bấm đo một chế độ: main, compute hoặc spawn. '
        'Không có warm-up hay đo không tải.',
    'limitations':
        'UI FPS là số callback/giây, chưa đối chiếu DevTools/FrameTiming. '
        'Lifecycle unknown cần kiểm tra cửa sổ thủ công. GC và tải nền có ảnh hưởng.',
    'runs': runs.map((run) => run.toJson()).toList(),
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());
}
