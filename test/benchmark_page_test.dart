import 'dart:async';

import 'package:isolate_demo/controllers/benchmark_controller.dart';
import 'package:isolate_demo/models/dataset_metadata.dart';
import 'package:isolate_demo/models/parse_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/screens/benchmark_page.dart';
import 'package:isolate_demo/services/dataset.dart';

Future<Dataset> smallDataset() async => const Dataset(
  '[{"amount":2}]',
  DatasetMetadata(
    id: 'test',
    bytes: 16,
    expected: ParseSummary(count: 1, totalAmount: 2),
    fnv1a32: 'test',
  ),
);

void main() {
  testWidgets('interaction stays enabled while waiting for dataset', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final pending = Completer<Dataset>();
    await tester.pumpWidget(
      MaterialApp(home: BenchmarkPage(loadDataset: () => pending.future)),
    );
    await tester.pump();
    expect(find.text('Đang nạp dữ liệu'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('run-main'))).onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('interaction-plus')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Số lần bấm +: 1'), findsOneWidget);
    pending.complete(await smallDataset());
    await tester.pump();
    expect(find.text('Sẵn sàng'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  test('unknown lifecycle is distinct from known background states', () {
    expect(isKnownBackground(null), isFalse);
    expect(isKnownBackground(AppLifecycleState.resumed), isFalse);
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
    ]) {
      expect(isKnownBackground(state), isTrue);
    }
  });
  testWidgets(
    'locks runs but keeps interaction; dispose during window is safe',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        const MaterialApp(home: BenchmarkPage(loadDataset: smallDataset)),
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('run-main')));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('run-compute')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('interaction-plus')));
      await tester.pump();
      expect(find.textContaining('Số lần bấm +: 1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 6));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('loading failure is visible and can be retried', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var attempts = 0;
    Future<Dataset> fail() async {
      attempts++;
      throw const FormatException('broken asset');
    }

    await tester.pumpWidget(
      MaterialApp(home: BenchmarkPage(loadDataset: fail)),
    );
    await tester.pump();
    expect(find.textContaining('broken asset'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('run-main'))).onPressed,
      isNull,
    );
    await tester.tap(find.text('Nạp lại dataset'));
    await tester.pump();
    expect(attempts, 2);
    await tester.pumpWidget(const SizedBox());
  });
}
