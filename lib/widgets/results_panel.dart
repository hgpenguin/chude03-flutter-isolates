import 'package:flutter/material.dart';

import '../models/run_record.dart';
import 'benchmark_panel.dart';

class ResultsPanel extends StatelessWidget {
  const ResultsPanel({
    super.key,
    required this.runs,
    required this.savedPath,
    required this.onCopy,
  });
  final List<RunRecord> runs;
  final String? savedPath;
  final VoidCallback? onCopy;
  String _number(num? value) => value?.toStringAsFixed(1) ?? '—';

  @override
  Widget build(BuildContext context) => BenchmarkPanel(
    title: '04  Kết quả thực đo',
    children: [
      if (runs.isEmpty) const Text('Chưa có kết quả đo.'),
      if (runs.isNotEmpty)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('# / Chế độ')),
              DataColumn(label: Text('Task ms')),
              DataColumn(label: Text('Parse ms')),
              DataColumn(label: Text('UI FPS ≈')),
              DataColumn(label: Text('Gap lớn nhất ms')),
              DataColumn(label: Text('Cửa sổ ms')),
              DataColumn(label: Text('Kết quả')),
            ],
            rows: runs.reversed
                .take(20)
                .map(
                  (r) => DataRow(
                    cells: [
                      DataCell(Text('${r.runId} / ${r.modeName}')),
                      DataCell(Text(_number(r.task?.elapsedMs))),
                      DataCell(Text(_number(r.task?.parseMs))),
                      DataCell(Text(_number(r.frames.estimatedUiFps))),
                      DataCell(Text(_number(r.frames.maxGapMs))),
                      DataCell(Text(_number(r.frames.windowMs))),
                      DataCell(
                        Text(
                          r.incomplete
                              ? 'Mẫu chưa đủ'
                              : r.task == null
                              ? 'Không có kết quả'
                              : '${r.task!.summary.count} / ${r.task!.summary.totalAmount}',
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      const SizedBox(height: 12),
      const Text(
        'Task gồm gọi/khởi tạo/truyền và nhận kết quả. Parse đo trong parser. '
        'UI FPS là số callback/giây; gap cho biết khoảng lâu nhất UI không cập nhật.',
      ),
      if (savedPath != null) SelectableText('Đã lưu JSON + CSV: $savedPath'),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onCopy,
          icon: const Icon(Icons.copy),
          label: const Text('Sao chép raw JSON'),
        ),
      ),
    ],
  );
}
