import 'dart:convert';
import 'dart:io';

// Không dùng random phụ thuộc phiên bản SDK. Quy tắc số học cố định.
Future<void> main() async {
  const count = 180000;
  var total = 0;
  final text = StringBuffer('[');
  for (var i = 0; i < count; i++) {
    final amount = (i * 37 + 17) % 100000;
    total += amount;
    if (i > 0) text.write(',');
    text.write(
      jsonEncode({
        'id': i + 1,
        'name': 'Giao dịch số ${i + 1}',
        'category': ['Học tập', 'Ăn uống', 'Di chuyển'][i % 3],
        'amount': amount,
        'note': 'Dữ liệu thực hành xử lý JSON bằng Dart và Flutter.',
      }),
    );
  }
  text.write(']');
  final bytes = utf8.encode(text.toString());
  if (bytes.length <= 15 * 1024 * 1024) {
    throw StateError('Dataset chưa đủ >15 MiB.');
  }
  var hash = 0x811c9dc5;
  for (final byte in bytes) {
    hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
  }
  await Directory('assets').create(recursive: true);
  await File('assets/transactions.json').writeAsBytes(bytes);
  final metadata = {
    'id': 'transactions-v1',
    'rule': '180000 rows; amount=(zeroBasedIndex*37+17)%100000',
    'bytes': bytes.length,
    'count': count,
    'totalAmount': total,
    'fnv1a32': hash.toRadixString(16).padLeft(8, '0'),
    'encoding': 'UTF-8',
  };
  await File('assets/metadata.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(metadata));
  stdout.writeln(jsonEncode(metadata));
}
