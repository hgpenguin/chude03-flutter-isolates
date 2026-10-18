import 'package:flutter/material.dart';

import 'benchmark_panel.dart';

class InteractionPanel extends StatelessWidget {
  const InteractionPanel({
    super.key,
    required this.animation,
    required this.taps,
    required this.onTap,
  });
  final Animation<double> animation;
  final int taps;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => BenchmarkPanel(
    title: '02  Quan sát khả năng phản hồi',
    children: [
      Row(
        children: [
          RotationTransition(
            turns: animation,
            child: Icon(
              Icons.sync,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Vòng quay chạy liên tục. Bấm + để thử phản hồi '
              'khi Main hoặc worker đang xử lý.\nSố lần bấm +: $taps',
            ),
          ),
          IconButton.filled(
            key: const Key('interaction-plus'),
            tooltip: 'Tăng bộ đếm tương tác',
            onPressed: onTap,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    ],
  );
}
