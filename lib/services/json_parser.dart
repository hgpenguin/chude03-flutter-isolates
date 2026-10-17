import 'dart:convert';
import 'dart:math' as math;

import '../models/parse_summary.dart';

typedef ProgressCallback = void Function(int done, int total);

// Main và worker dùng chung logic kiểm tra và tổng hợp.
// jsonDecode là một lời gọi nguyên khối nên chỉ báo được tiến độ ở bước kiểm tra.
ParseSummary parseAndSummarize(
  String jsonText, {
  ProgressCallback? onProgress,
}) {
  final records = jsonDecode(jsonText);
  if (records is! List<dynamic>) {
    throw const FormatException('JSON phải là danh sách.');
  }

  final total = records.length;
  // Khoảng 10 lần báo: đủ để thấy tiến độ, không làm ngập port bằng message.
  final step = math.max(1, (total / 10).ceil());
  var totalAmount = 0;
  for (var i = 0; i < total; i++) {
    final entry = records[i];
    if (entry is! Map<String, dynamic>) {
      throw FormatException('Bản ghi ${i + 1} phải là Map.');
    }

    final amount = entry['amount'];
    if (amount is! int) {
      throw FormatException('Bản ghi ${i + 1}: amount phải là số nguyên.');
    }
    totalAmount += amount;
    if (onProgress != null && (i + 1) % step == 0 && i + 1 < total) {
      onProgress(i + 1, total);
    }
  }
  onProgress?.call(total, total);

  return ParseSummary(count: total, totalAmount: totalAmount);
}
