import 'package:flutter/material.dart';

import '../models/dataset_metadata.dart';
import 'benchmark_panel.dart';

class DatasetPanel extends StatelessWidget {
  const DatasetPanel({
    super.key,
    required this.status,
    required this.detail,
    required this.metadata,
    required this.onReload,
  });
  final String status;
  final String detail;
  final DatasetMetadata? metadata;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final data = metadata;
    return BenchmarkPanel(
      title: '01  Dữ liệu & trạng thái',
      children: [
        Text(
          status,
          key: const Key('benchmark-status'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(detail),
        const SizedBox(height: 10),
        if (data != null)
          SelectableText(
            '${data.id} • ${data.bytes} byte UTF-8 '
            '(${(data.bytes / (1024 * 1024)).toStringAsFixed(2)} MiB)\n'
            '${data.expected.count} bản ghi • tổng amount: ${data.expected.totalAmount} '
            '• FNV-1a: ${data.fnv1a32}',
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
            label: const Text('Nạp lại dataset'),
          ),
        ),
      ],
    );
  }
}
