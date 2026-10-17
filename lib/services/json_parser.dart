import 'dart:convert';

import '../models/parse_summary.dart';

// Main và worker dùng chung logic kiểm tra và tổng hợp.
ParseSummary parseAndSummarize(String jsonText) {
  final records = jsonDecode(jsonText);
  if (records is! List<dynamic>) {
    throw const FormatException('JSON phải là danh sách.');
  }

  var totalAmount = 0;
  for (var i = 0; i < records.length; i++) {
    final entry = records[i];
    if (entry is! Map<String, dynamic>) {
      throw FormatException('Bản ghi ${i + 1} phải là Map.');
    }

    final amount = entry['amount'];
    if (amount is! int) {
      throw FormatException('Bản ghi ${i + 1}: amount phải là số nguyên.');
    }
    totalAmount += amount;
  }

  return ParseSummary(count: records.length, totalAmount: totalAmount);
}
