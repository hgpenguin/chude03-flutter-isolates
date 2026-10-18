# Isolate Lab — Chủ đề 03

Ứng dụng Flutter Desktop so sánh việc parse JSON trên Main Isolate, `compute` và `Isolate.spawn`. Vòng quay và nút + giúp quan sát giao diện khi xử lý. App ghi thời gian tác vụ, nhịp callback UI và khoảng ngừng cập nhật dài nhất.

Source: [hgpenguin/chude03-flutter-isolates](https://github.com/hgpenguin/chude03-flutter-isolates).

## Dữ liệu

File `assets/transactions.json` có **28.497.671 byte UTF-8 (27,18 MiB)**, **180.000 bản ghi**. Kết quả đúng là tổng `amount` **8.967.430.000**, checksum FNV-1a32 `5598744f`. Dữ liệu đã có trong source; app chạy offline.

## Chạy ứng dụng

Phiên bản đã dùng: Flutter **3.47.7**, Dart **3.13.5**. Windows cần Visual Studio với Desktop development with C++; Mac cần Flutter và Xcode đã cấu hình.

Clone bằng PowerShell (Windows) hoặc Terminal (Mac), tại thư mục muốn lưu dự án:

```sh
git clone https://github.com/hgpenguin/chude03-flutter-isolates.git
cd chude03-flutter-isolates
```

Windows, dùng PowerShell tại cùng thư mục:

```powershell
flutter run -d windows
```

Mac, dùng Terminal tại cùng thư mục:

```sh
flutter run -d macos
```

Nếu cần tạo lại dữ liệu, chạy `dart run tool/generate_dataset.dart` tại thư mục app. Generator dùng quy tắc cố định và tạo cả metadata.

## Cách thử

1. Chờ **Sẵn sàng**. App kiểm tra dung lượng, checksum và giải mã UTF-8 trong worker.
2. Chạy lần lượt **Main Isolate**, **compute**, **Isolate.spawn**. Quan sát vòng quay, thử nút + và so sánh kết quả.
3. Cả ba chế độ phải trả cùng số bản ghi và tổng amount.
4. Bấm **Thử JSON lỗi qua ports**, xem thông báo, sau đó chạy lại một chế độ.

**Nạp lại dataset** sẽ xóa các kết quả đang hiển thị để bắt đầu phiên mới; các file báo cáo đã ghi vẫn được giữ.

## Lấy số liệu

Tại thư mục app, PowerShell Windows dùng `flutter run --profile -d windows`; Terminal Mac dùng `flutter run --profile -d macos`.

Mỗi lần bấm **Main Isolate**, **compute** hoặc **Isolate.spawn** tạo một mẫu đo cho chế độ đã chọn. Giữ cửa sổ hiện trên màn hình và hạn chế đổi tải máy trong khi đo. Nếu cần nhiều mẫu cho báo cáo, tự chạy lại các chế độ với cùng điều kiện; ghi số lần đo thực tế.

JSON và CSV được lưu sau phép đo vào `benchmark_results/runs-…/report.json` và `report.csv`. Đường dẫn hiện trên màn hình; có thể sao chép JSON. Đổi nơi lưu bằng `--dart-define=BENCHMARK_OUTPUT=<thư mục>`; ghi điều kiện máy bằng `--dart-define=BENCHMARK_MACHINE=<mô tả>`. Flutter SDK tự cung cấp phiên bản vào báo cáo.

Tại thư mục app, PowerShell hoặc Terminal, thay đường dẫn bằng báo cáo vừa xuất:

```sh
dart run tool/summarize_benchmark.dart benchmark_results/runs-XXX/report.json
```

`taskMs` gồm thời gian gọi, khởi tạo, truyền và nhận kết quả. `parseMs` đo bên trong hàm parse/kiểm tra/tổng hợp. `estimatedUiFps` là số callback UI mỗi giây thực tế; `maxGapMs` là khoảng lâu nhất không có callback, gồm cả hai biên cửa sổ. Worker có thể làm UI mượt hơn nhưng mất nhiều tổng thời gian hơn.

Các phép so sánh phải dùng cùng máy, dữ liệu và build mode. Phép đo callback chưa đối chiếu DevTools/FrameTiming; Mẫu `incomplete` bị loại khỏi bảng tổng hợp; lifecycle khác `resumed` lúc bắt đầu hoặc trong khi đo cũng làm mẫu bị loại. Khi lifecycle là `unknown`, cần quan sát cửa sổ thủ công. Xem [phương pháp đo](docs/BENCHMARK.md).

## Cấu trúc

```text
lib/
  main.dart
  screens/       màn hình
  widgets/       các panel
  controllers/   trạng thái và điều phối đo
  models/        dữ liệu có kiểu
  services/      dataset, parser, isolate, metrics, ghi báo cáo
assets/          JSON và metadata
test/            kiểm thử
tool/            tạo dữ liệu và tổng hợp kết quả
windows/, macos/ runner cho từng nền tảng
docs/            yêu cầu, kiến trúc, phương pháp và kịch bản
```

Giữ `pubspec.yaml`, `pubspec.lock`, `.metadata` và `analysis_options.yaml` khi chuyển source. `build/`, `.dart_tool/` và Flutter SDK được tạo/cài riêng trên máy nhận.

## Tài liệu

- [Yêu cầu và đầu việc còn lại](docs/REQUIREMENTS.md)
- [Kiến trúc, SpawnJob và cách tính FPS/gap](docs/ARCHITECTURE.md)
- [Kết quả Windows của phiên bản trước refactor](benchmark_results/RESULTS.md)
- [Kịch bản demo và Q&A](docs/DEMO.md)
- [Phân công hai thành viên](TEAM.md)
- [Phần việc A: dữ liệu, logic, Isolate và bằng chứng Git](docs/PHAN_VIEC_A.md)
- [Bàn giao thay đổi và commit theo hai thành viên](docs/GIT_HANDOFF.md)
