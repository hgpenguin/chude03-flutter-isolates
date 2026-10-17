import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/dataset_metadata.dart';
import '../models/parse_summary.dart';

class Dataset {
  const Dataset(this.text, this.metadata);
  final String text;
  final DatasetMetadata metadata;

  static Future<Dataset> load() async {
    // AssetBundle thuộc Main. Chỉ chuyển bytes và chuỗi metadata tới worker.
    final data = await rootBundle.load('assets/transactions.json');
    final metadataJson = await rootBundle.loadString('assets/metadata.json');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    return compute(
      prepareDataset,
      DatasetInput(bytes, metadataJson),
      debugLabel: 'dataset-checksum-utf8',
    );
  }

  void verify(ParseSummary summary) {
    if (summary != metadata.expected) {
      throw StateError('Kết quả không khớp metadata, không dùng mẫu đo này.');
    }
  }
}

class DatasetInput {
  const DatasetInput(this.bytes, this.metadataJson);
  final Uint8List bytes;
  final String metadataJson;
}

// Toàn bộ bước CPU chuẩn bị dữ liệu chạy trong worker, trước benchmark.
Dataset prepareDataset(DatasetInput input) {
  final metadata = DatasetMetadata.fromJson(jsonDecode(input.metadataJson));
  if (input.bytes.length <= 15 * 1024 * 1024 ||
      input.bytes.length != metadata.bytes) {
    throw const FormatException(
      'Kích thước dataset không đúng hoặc chưa đủ >15 MiB.',
    );
  }
  var hash = 0x811c9dc5;
  for (final byte in input.bytes) {
    hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
  }
  if (hash.toRadixString(16).padLeft(8, '0') != metadata.fnv1a32) {
    throw const FormatException('Checksum dataset không đúng.');
  }
  return Dataset(utf8.decode(input.bytes), metadata);
}
