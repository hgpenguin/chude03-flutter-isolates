# Phân công nhóm — Chủ đề 03

| Thành viên | GitHub | Phụ trách |
|---|---|---|
| Nguyễn Thái Hoàng | [hgpenguin](https://github.com/hgpenguin) | Dữ liệu, parser JSON, xử lý trên Main / `compute` / `Isolate.spawn` và ports; kiến trúc, README |
| Lê Trương Uyển Nhi | [nhi2h4ever](https://github.com/nhi2h4ever) | Giao diện, quản lý trạng thái, đo hiệu năng, xuất và tổng hợp kết quả |

Tỷ lệ công việc: Hoàng 50%, Nhi 50%.

## File phụ trách

Người phụ trách sửa chính; người còn lại review. Cần sửa file của người kia thì thống nhất trước.

| Hoàng | Nhi |
|---|---|
| `lib/services/dataset.dart` | `lib/main.dart` |
| `lib/services/json_parser.dart` | `lib/screens/`, `lib/widgets/` |
| `lib/services/processing.dart` | `lib/controllers/benchmark_controller.dart` |
| `lib/models/worker_message.dart`, `task_result.dart`, `parse_summary.dart`, `dataset_metadata.dart` | `lib/services/frame_metrics.dart`, `report_writer.dart` |
| `tool/generate_dataset.dart` | `lib/models/benchmark_report.dart`, `run_record.dart`, `frame_stats.dart` |
| `test/dataset_test.dart`, `json_parser_test.dart`, `compute_parser_test.dart`, `processing_test.dart` | `tool/summarize_benchmark.dart` |
| `docs/ARCHITECTURE.md`, `README.md` | `test/benchmark_page_test.dart`, `benchmark_controller_test.dart`, `frame_metrics_test.dart`, `report_writer_test.dart` |
| | `docs/BENCHMARK.md`, `benchmark_results/` |

## Commit

Xem toàn bộ commit theo người: [Hoàng](https://github.com/hgpenguin/chude03-flutter-isolates/commits/main?author=hgpenguin), [Nhi](https://github.com/hgpenguin/chude03-flutter-isolates/commits/main?author=nhi2h4ever).

| Người | Commit | Nội dung |
|---|---|---|
| Hoàng | `8f1ce1d` | Khởi tạo ứng dụng: dataset, parser, ba chế độ xử lý, models, báo cáo, test |
| Hoàng | `648d6a7`, `5d7ae14` | Tài liệu kiến trúc, hướng dẫn chạy, tiêu chí lifecycle |
| Hoàng | `d70d0a7`, `f4d2967` | Ghi nhận phân công và đóng góp |
| Hoàng | `4c4326e` … `8979b77` | Viết lại README, dọn tài liệu thừa |
| Nhi | `30b2428`, `7a3e32c` | Worker gửi tiến độ qua `SendPort`, test tiến độ và hủy worker |
| Nhi | `f8a812f`, `1df1617` | Thanh tiến độ, nút Hủy trên UI; tài liệu luồng tiến độ |
| Nhi | `e82dfd9`, `7509606` | Rút gọn demo còn ba chế độ và xử lý lỗi; merge PR #1 |
| Nhi | `25fe1d9` … `08b0d37` | Refactor controller, ReportWriter, bảng kết quả; bỏ code thừa |

## Kiểm chứng

- `flutter analyze` không lỗi, `flutter test` 34/34 (18/10/2026).
- Windows: số liệu profile trong `benchmark_results/RESULTS.md`.
- macOS (Nhi, 18/10/2026): build và chạy đủ ba chế độ, cùng kết quả 180000 bản ghi / 8967430000. Gap lớn nhất: main 348 ms, compute 67 ms, spawn 50 ms.

## Trình bày 20 phút

| Phần | Hoàng | Nhi |
|---|---|---|
| Lý thuyết, kiến trúc (10 phút) | Single/multi-thread, async, bộ nhớ độc lập, parser, `compute`/`spawn`, ports | Kiến trúc app, UI/state, cách đo, kết quả và giới hạn |
| Demo, code (5 phút) | Parser và luồng ports; demo JSON lỗi và phục hồi | Chạy ba chế độ, thao tác animation/nút +, đọc số liệu |
| Q&A (5 phút) | Parser, Isolate, ports, lỗi/timeout/cleanup | UI, lifecycle, FPS/gap, tính công bằng của phép đo |
