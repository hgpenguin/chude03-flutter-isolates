import 'parse_summary.dart';

class DatasetMetadata {
  const DatasetMetadata({
    required this.id,
    required this.bytes,
    required this.expected,
    required this.fnv1a32,
    this.rule = '',
    this.encoding = 'UTF-8',
  });

  final String id;
  final int bytes;
  final ParseSummary expected;
  final String fnv1a32;
  final String rule;
  final String encoding;

  factory DatasetMetadata.fromJson(Object? json) {
    if (json
        case {
          'id': String id,
          'bytes': int bytes,
          'count': int count,
          'totalAmount': int total,
          'fnv1a32': String hash,
          'rule': String rule,
          'encoding': 'UTF-8',
        }
        when bytes > 0 && count >= 0) {
      return DatasetMetadata(
        id: id,
        bytes: bytes,
        expected: ParseSummary(count: count, totalAmount: total),
        fnv1a32: hash,
        rule: rule,
      );
    }
    throw const FormatException('Metadata thiếu trường hoặc sai kiểu dữ liệu.');
  }

  Map<String, Object> toJson() => {
    'id': id,
    'bytes': bytes,
    'count': expected.count,
    'totalAmount': expected.totalAmount,
    'fnv1a32': fnv1a32,
    'rule': rule,
    'encoding': encoding,
  };
}
