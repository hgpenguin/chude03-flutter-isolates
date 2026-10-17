import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isolate_demo/models/task_result.dart';
import 'package:isolate_demo/models/parse_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/services/dataset.dart';
import 'package:isolate_demo/services/processing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('background preparation rejects broken checksum and metadata', () async {
    final data = await rootBundle.load('assets/transactions.json');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final metadata = jsonDecode(
      await rootBundle.loadString('assets/metadata.json'),
    ) as Map<String, dynamic>;
    metadata['fnv1a32'] = '00000000';
    await expectLater(
      compute(prepareDataset, DatasetInput(bytes, jsonEncode(metadata))),
      throwsFormatException,
    );
    metadata['bytes'] = 'not an integer';
    await expectLater(
      compute(prepareDataset, DatasetInput(bytes, jsonEncode(metadata))),
      throwsFormatException,
    );
  });

  test(
    'actual UTF-8 asset exceeds 15 MiB, checksum and all modes match',
    () async {
      final dataset = await Dataset.load();
      expect(dataset.metadata.bytes, greaterThan(15 * 1024 * 1024));
      for (final mode in ProcessingMode.values) {
        final result = await processJson(mode, dataset.text);
        dataset.verify(result.summary);
      }
      expect(
        () => dataset.verify(const ParseSummary(count: 1, totalAmount: 0)),
        throwsStateError,
      );
    },
  );
}
