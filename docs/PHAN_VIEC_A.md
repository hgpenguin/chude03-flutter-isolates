# Phần việc A — dữ liệu, logic và Isolate

Tài khoản Git: **hgpenguin** (`thaihoangh216@gmail.com`). Ngày rà soát: **18/10/2026**.

Tài liệu đối chiếu phần việc được giao với mã nguồn, kiểm thử và lịch sử Git để phục vụ báo cáo nhóm.

## 1. Dữ liệu và logic

| File | Nội dung đối chiếu |
|---|---|
| [`dataset.dart`](../lib/services/dataset.dart) | Đọc asset trên Main; dùng `compute(prepareDataset, ...)` để kiểm kích thước, checksum FNV-1a32 và giải mã UTF-8; đối chiếu kết quả với metadata. |
| [`json_parser.dart`](../lib/services/json_parser.dart) | Parser chung cho ba chế độ; kiểm JSON là danh sách, từng bản ghi là Map và `amount` là số nguyên; trả số bản ghi và tổng tiền. |
| [`generate_dataset.dart`](../tool/generate_dataset.dart) | Sinh dữ liệu bằng quy tắc cố định, ghi JSON và metadata gồm byte/count/tổng/checksum. |

Dataset hiện có: **28.497.671 byte**, **180.000 bản ghi**, tổng `amount` **8.967.430.000**, checksum **`5598744f`**. Các giá trị nằm trong [`assets/metadata.json`](../assets/metadata.json) và được test với asset thực tế.

## 2. Isolate, lỗi và cleanup

[`processing.dart`](../lib/services/processing.dart) cung cấp ba chế độ Main, `compute` và `Isolate.spawn`. Các chế độ dùng cùng parser; `parseMs` đo bên trong parser, `elapsedMs` đo toàn lời gọi.

`SpawnJob` tạo `ReceivePort`, truyền `SendPort` trong `WorkerRequest` và nhận kết quả/lỗi/tiến độ. Mỗi job chạy một lần. Timeout mặc định là 60 giây; worker thoát sớm hoặc gửi lỗi làm Future kết thúc với lỗi tương ứng. `finally` hủy timer và subscription, đóng port và kill worker. Khi hủy trong lúc `Isolate.spawn` chưa hoàn tất, worker được tạo muộn cũng bị kill.

Tiến độ và nút Hủy hiện có trong phiên bản tích hợp: `WorkerProgress` được gửi sau bước `jsonDecode`, trong vòng kiểm tra bản ghi; controller cập nhật UI và gọi `SpawnJob.cancel()` khi hủy. Luồng chi tiết ở [ARCHITECTURE.md](ARCHITECTURE.md).

## 3. Kiểm thử và cách kiểm tra lại

| File test | Tình huống kiểm tra |
|---|---|
| [`dataset_test.dart`](../test/dataset_test.dart) | Checksum/metadata sai; dataset thực tế lớn hơn 15 MiB; cả ba mode khớp metadata; từ chối kết quả sai. |
| [`json_parser_test.dart`](../test/json_parser_test.dart) | Đếm/tính tổng, danh sách rỗng, số âm; JSON sai và các kiểu `amount` không hợp lệ. |
| [`compute_parser_test.dart`](../test/compute_parser_test.dart) | Main và compute cùng kết quả; lỗi parser được truyền về nơi gọi. |
| [`processing_test.dart`](../test/processing_test.dart) | Ba mode tương đương; lỗi dữ liệu và lỗi worker giữ stack; thoát sớm, timeout, hủy khi spawn, cleanup; tiến độ qua ports và hủy sau message tiến độ. |

Chạy từ thư mục chứa `pubspec.yaml`, với Flutter trong PATH:

```sh
flutter analyze
flutter test test/dataset_test.dart test/json_parser_test.dart test/compute_parser_test.dart test/processing_test.dart --reporter expanded
```

Kết quả chạy trên Windows ngày **18/10/2026**, sau khi đồng bộ tới `1df1617`: `flutter analyze` báo **No issues found**; bốn file test trên có **23 test pass**. Đây là kiểm tra tự động cho phần dữ liệu/xử lý, chưa thay thế thao tác demo UI hoặc kiểm tra trên macOS.

## 4. Bằng chứng Git và phạm vi đóng góp

Mã ban đầu đã được đưa vào lịch sử chung trong commit [8f1ce1d — Initial Flutter desktop isolate benchmark with typed models and reports](https://github.com/hgpenguin/chude03-flutter-isolates/commit/8f1ce1d9d31ce2a27f027ab8a3a6a0b5bde20cc6), tác giả Git **hgpenguin**. Commit này chứa toàn dự án, bao gồm các file thuộc phần A ở trên; Git không tách từng đầu việc thành commit riêng trong lần nhập source ban đầu.

Các bổ sung tiến độ/Hủy trên GitHub mang tên tác giả **Lê Trương Uyển Nhi**, cần giữ đúng khi đối chiếu đóng góp:

| Commit | Nội dung |
|---|---|
| [30b2428](https://github.com/hgpenguin/chude03-flutter-isolates/commit/30b2428) | Gửi tiến độ worker qua SendPort. |
| [7a3e32c](https://github.com/hgpenguin/chude03-flutter-isolates/commit/7a3e32c) | Kiểm thử tiến độ và hủy worker. |
| [f8a812f](https://github.com/hgpenguin/chude03-flutter-isolates/commit/f8a812f) | Hiển thị tiến độ và nút Hủy trong UI. |
| [1df1617](https://github.com/hgpenguin/chude03-flutter-isolates/commit/1df1617e827943acc7faa0b94afa43bf0a11d7de) | Mô tả luồng tiến độ và hủy worker. |

Lần cập nhật ngày 18/10/2026 dưới tài khoản hgpenguin bổ sung bản đối chiếu này, ghi nhận kiểm tra phần A và liên kết từ README/TEAM. Đây là đóng góp tài liệu và kiểm chứng trên phiên bản tích hợp.

Để xem các commit chạm tới phần dữ liệu/xử lý:

```sh
git log --format="%h %an <%ae> %s" -- lib/services/dataset.dart lib/services/json_parser.dart lib/services/processing.dart tool/generate_dataset.dart test/dataset_test.dart test/json_parser_test.dart test/compute_parser_test.dart test/processing_test.dart
```

Hướng dẫn clone/chạy và repo: [README.md](../README.md). Bảng phân công và đóng góp: [TEAM.md](../TEAM.md).
