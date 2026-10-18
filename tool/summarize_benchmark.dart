import 'dart:convert';
import 'dart:io';

// values phải được sắp xếp tăng dần.
double median(List<double> values) {
  final middle = values.length ~/ 2;
  return values.length.isOdd
      ? values[middle]
      : (values[middle - 1] + values[middle]) / 2;
}

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Dùng: dart run tool/summarize_benchmark.dart report.json');
    exitCode = 64;
    return;
  }
  final report = jsonDecode(File(args.single).readAsStringSync()) as Map;
  final runs = (report['runs'] as List).cast<Map>();
  stdout.writeln('# Kết quả profile Desktop\n');
  stdout.writeln('Raw data: `${args.single}`\n');
  stdout.writeln('Môi trường: `${jsonEncode(report['environment'])}`\n');
  stdout.writeln('Dataset: `${jsonEncode(report['dataset'])}`\n');
  stdout.writeln(
    '| Chế độ | n hợp lệ | Task ms median [min–max] | UI FPS ≈ median [min–max] | Gap ms median [min–max] |',
  );
  stdout.writeln('|---|---:|---|---|---|');
  for (final mode in ['main', 'compute', 'spawn']) {
    final rows = runs
        .where((r) => r['mode'] == mode && r['incomplete'] == false)
        .toList();
    String describe(String key) {
      final values =
          rows
              .map((r) => r[key])
              .whereType<num>()
              .map((v) => v.toDouble())
              .toList()
            ..sort();
      if (values.isEmpty) return '—';
      String fixed(double v) => v.toStringAsFixed(2);
      return '${fixed(median(values))} '
          '[${fixed(values.first)}–${fixed(values.last)}]';
    }

    stdout.writeln(
      '| $mode | ${rows.length} | ${describe('taskMs')} | ${describe('estimatedUiFps')} | ${describe('maxGapMs')} |',
    );
  }
  stdout.writeln(
    '\nMẫu chưa đủ/lỗi: ${runs.where((r) => r['incomplete'] != false).length}.',
  );
  stdout.writeln('\n${report['method']}\n\nGiới hạn: ${report['limitations']}');
}
