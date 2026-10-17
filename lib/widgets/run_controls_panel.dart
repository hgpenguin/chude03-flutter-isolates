import 'package:flutter/material.dart';

import '../models/task_result.dart';
import 'benchmark_panel.dart';

class RunControlsPanel extends StatelessWidget {
  const RunControlsPanel({
    super.key,
    required this.ready,
    required this.onRun,
    required this.onBaseline,
    required this.onBatch,
    required this.onInvalid,
  });
  final bool ready;
  final ValueChanged<ProcessingMode> onRun;
  final VoidCallback onBaseline;
  final VoidCallback onBatch;
  final VoidCallback onInvalid;

  @override
  Widget build(BuildContext context) => BenchmarkPanel(
    title: '03  Chạy phép đo',
    children: [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final mode in ProcessingMode.values)
            FilledButton(
              key: Key('run-${mode.name}'),
              onPressed: ready ? () => onRun(mode) : null,
              child: Text(mode.label),
            ),
          OutlinedButton(
            onPressed: ready ? onBaseline : null,
            child: const Text('Đo không tải'),
          ),
          OutlinedButton(
            onPressed: ready ? onBatch : null,
            child: const Text('Warm-up + 5 vòng (~80 giây)'),
          ),
          TextButton(
            onPressed: ready ? onInvalid : null,
            child: const Text('Thử JSON lỗi qua ports'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const Text(
        'Mỗi cửa sổ mục tiêu 5 giây, gồm cả khoảng UI đứng. '
        'Dùng profile khi lấy số liệu báo cáo.',
      ),
    ],
  );
}
