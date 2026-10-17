import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/benchmark_controller.dart';
import '../services/dataset.dart';
import '../widgets/dataset_panel.dart';
import '../widgets/interaction_panel.dart';
import '../widgets/results_panel.dart';
import '../widgets/run_controls_panel.dart';

class BenchmarkPage extends StatefulWidget {
  const BenchmarkPage({super.key, this.loadDataset = Dataset.load});
  final Future<Dataset> Function() loadDataset;

  @override
  State<BenchmarkPage> createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage>
    with SingleTickerProviderStateMixin {
  late final BenchmarkController _controller;
  late final AnimationController _animation;
  int _taps = 0;

  @override
  void initState() {
    super.initState();
    _controller = BenchmarkController(loadDataset: widget.loadDataset);
    _animation =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(_controller.recordFrame)
          ..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.load();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.displayRefreshRateHz = View.of(context).display.refreshRate;
  }

  Future<void> _copyReport() async {
    await Clipboard.setData(ClipboardData(text: _controller.reportJson()));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã sao chép JSON kết quả')));
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ISOLATE LAB  /  Chủ đề 03')),
    body: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Cùng dữ liệu. Khác nơi xử lý.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'So sánh Main Isolate, compute và message passing trên Desktop.',
              ),
              const SizedBox(height: 16),
              DatasetPanel(
                status: _controller.status,
                detail: _controller.detail,
                metadata: _controller.dataset?.metadata,
                onReload: _controller.busy || _controller.loading
                    ? null
                    : _controller.load,
              ),
              InteractionPanel(
                animation: _animation,
                taps: _taps,
                onTap: () => setState(() => _taps++),
              ),
              RunControlsPanel(
                ready: _controller.ready,
                onRun: (mode) => _controller.execute(mode: mode),
                onBaseline: () => _controller.execute(),
                onBatch: () => _controller.execute(batch: true),
                onInvalid: () => _controller.execute(invalid: true),
              ),
              ResultsPanel(
                runs: _controller.runs,
                savedPath: _controller.savedPath,
                onCopy: _controller.busy || _controller.runs.isEmpty
                    ? null
                    : _copyReport,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
