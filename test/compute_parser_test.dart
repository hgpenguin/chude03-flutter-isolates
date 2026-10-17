import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/services/json_parser.dart';

void main() {
  test('native compute and Main return equivalent summaries', () async {
    for (final input in <String>[
      '[]',
      '[{"amount": 50}, {"amount": 80}]',
      '[{"amount": -9}, {"amount": 12}]',
    ]) {
      final mainResult = parseAndSummarize(input);
      final workerResult = await compute(parseAndSummarize, input);
      expect(workerResult, mainResult);
    }
  });

  test('native compute propagates parser errors to the caller', () async {
    for (final input in <String>[
      '[',
      '[{"name": "Chi"}]',
      '[{"amount": "500"}]',
    ]) {
      await expectLater(
        compute(parseAndSummarize, input),
        throwsFormatException,
      );
    }
  });
}
