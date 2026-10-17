import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/controllers/benchmark_controller.dart';
import 'package:isolate_demo/models/dataset_metadata.dart';
import 'package:isolate_demo/models/parse_summary.dart';
import 'package:isolate_demo/services/dataset.dart';

const sample = Dataset(
  '[{"amount":2}]',
  DatasetMetadata(
    id: 'test',
    bytes: 14,
    expected: ParseSummary(count: 1, totalAmount: 2),
    fnv1a32: 'test',
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load is locked; late result after disposal is ignored', () async {
    final pending = Completer<Dataset>();
    var calls = 0;
    final controller = BenchmarkController(
      loadDataset: () {
        calls++;
        return pending.future;
      },
    );
    var notifications = 0;
    controller.addListener(() => notifications++);
    final loading = controller.load();
    await controller.load();
    expect(calls, 1);
    expect(controller.loading, isTrue);
    expect(controller.ready, isFalse);
    controller.dispose();
    final before = notifications;
    pending.complete(sample);
    await loading;
    expect(notifications, before);
    expect(controller.dataset, isNull);
  });

  test(
    'failed reload invalidates old data and a later retry recovers',
    () async {
      var calls = 0;
      final controller = BenchmarkController(
        loadDataset: () async {
          if (++calls == 2) throw const FormatException('broken checksum');
          return sample;
        },
      );
      addTearDown(controller.dispose);
      await controller.load();
      expect(controller.ready, isTrue);
      await controller.load();
      expect(controller.ready, isFalse);
      expect(controller.detail, contains('broken checksum'));
      await controller.load();
      expect(controller.ready, isTrue);
    },
  );

  test(
    'expected bad JSON is reported, unlocks controller and permits reload',
    () async {
      final controller = BenchmarkController(loadDataset: () async => sample);
      addTearDown(controller.dispose);
      await controller.load();
      await controller.execute(invalid: true);
      expect(controller.status, 'Đã bắt lỗi dữ liệu đúng dự kiến');
      expect(controller.ready, isTrue);
      expect(controller.runs, isEmpty);
      await controller.load();
      expect(controller.status, 'Sẵn sàng');
    },
  );
}
