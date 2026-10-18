import 'package:flutter/material.dart';

import '../models/task_result.dart';
import 'benchmark_panel.dart';

class RunControlsPanel extends StatelessWidget {
  const RunControlsPanel({
    super.key,
    required this.ready,
    required this.onRun,
    required this.onInvalid,
    this.progress,
    this.onCancel,
  });
  final bool ready;
  final ValueChanged<ProcessingMode> onRun;
  final VoidCallback onInvalid;

  /// Tiến độ 0..1 do worker gửi qua SendPort; null khi không chạy Isolate.spawn.
  final double? progress;
  final VoidCallback? onCancel;

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
          TextButton(
            onPressed: ready ? onInvalid : null,
            child: const Text('Thử JSON lỗi qua ports'),
          ),
        ],
      ),
      if (progress case final value?) ...[
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Isolate.spawn: '),
            Expanded(
              child: LinearProgressIndicator(
                key: const Key('spawn-progress'),
                value: value,
              ),
            ),
            const SizedBox(width: 12),
            Text('${(value * 100).round()}%'),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              key: const Key('cancel-spawn'),
              onPressed: onCancel,
              icon: const Icon(Icons.stop),
              label: const Text('Hủy worker'),
            ),
          ],
        ),
      ],
      const SizedBox(height: 12),
      const Text(
        'Mỗi cửa sổ mục tiêu 5 giây, gồm cả khoảng UI đứng. '
        'Dùng profile khi lấy số liệu báo cáo.',
      ),
    ],
  );
}
