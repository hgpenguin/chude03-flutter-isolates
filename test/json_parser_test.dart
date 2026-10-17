import 'package:isolate_demo/models/parse_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_demo/services/json_parser.dart';

void main() {
  test('returns actual record count and integer sum', () {
    expect(
      parseAndSummarize('[{"amount": 50}, {"amount": 80}]'),
      const ParseSummary(count: 2, totalAmount: 130),
    );
    expect(
      parseAndSummarize('[]'),
      const ParseSummary(count: 0, totalAmount: 0),
    );
    expect(
      parseAndSummarize('[{"amount": -9}, {"amount": 12}]'),
      const ParseSummary(count: 2, totalAmount: 3),
    );
  });

  final invalidInputs = <String, String>{
    'malformed JSON': '[',
    'object at root': '{"amount": 50}',
    'non-map entry': '[null]',
    'missing amount': '[{"name": "Chi"}]',
    'string amount': '[{"amount": "500"}]',
    'fractional amount': '[{"amount": 1.5}]',
    'boolean amount': '[{"amount": true}]',
    'invalid record after valid one': '[{"amount": 50}, {}]',
  };
  for (final entry in invalidInputs.entries) {
    test('rejects ${entry.key} instead of returning a partial sum', () {
      expect(() => parseAndSummarize(entry.value), throwsFormatException);
    });
  }
}
