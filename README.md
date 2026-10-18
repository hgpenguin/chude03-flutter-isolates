# Isolate Lab — Chủ đề 03

Ứng dụng Flutter Desktop so sánh việc parse JSON trên Main Isolate, `compute` và `Isolate.spawn`. Vòng quay và nút + giúp quan sát giao diện khi xử lý. App ghi thời gian tác vụ, nhịp callback UI và khoảng ngừng cập nhật dài nhất.

Source: [hgpenguin/chude03-flutter-isolates](https://github.com/hgpenguin/chude03-flutter-isolates).

## Dữ liệu

File `assets/transactions.json` có **28.497.671 byte UTF-8 (27,18 MiB)**, **180.000 bản ghi**. Kết quả đúng là tổng `amount` **8.967.430.000**, checksum FNV-1a32 `5598744f`. Dữ liệu đã có trong source; app chạy offline.

## Chạy ứng dụng từ mã nguồn

Dự án có cấu hình cho **Windows và macOS Desktop**. Windows đã được kiểm tra build profile và chạy bộ test; macOS cần được kiểm tra trên máy Mac thực tế. Chọn hướng dẫn đúng hệ điều hành đang sử dụng.

Phiên bản đã kiểm tra: **Flutter 3.47.7**, kèm **Dart 3.13.5**. `pubspec.yaml` yêu cầu Dart từ 3.13.5 đến trước 4.0.0. Để dùng cùng môi trường đã kiểm tra, chọn Flutter 3.47.7 trong [kho phiên bản Flutter](https://docs.flutter.dev/install/archive). Dart có sẵn trong Flutter SDK.

Lần thiết lập đầu cần Internet để tải SDK và các gói phụ thuộc. Sau khi dựng xong, app dùng dataset có sẵn và hoạt động offline.

### 1. Cài công cụ cho máy của bạn

**Windows**

1. Tải và giải nén Flutter SDK theo [hướng dẫn cài Flutter](https://docs.flutter.dev/install/manual). Ghi lại thư mục SDK đã chọn; thư mục này chứa `bin/flutter.bat`.
2. Trong Windows, tìm **Edit environment variables for your account**. Chọn **Path → Edit → New**, thêm đường dẫn tới thư mục `bin` của Flutter SDK. Ví dụ: nếu SDK ở `C:\develop\flutter`, thêm `C:\develop\flutter\bin`. Dùng đường dẫn thực tế trên máy của bạn và giữ các mục PATH hiện có.
3. Bấm OK để lưu, đóng rồi mở lại PowerShell. Nếu dùng terminal trong VS Code, mở lại VS Code để nhận PATH mới. Xem [hướng dẫn PATH](https://docs.flutter.dev/install/add-to-path).
4. Cài **Visual Studio** và chọn workload **Desktop development with C++**, gồm các thành phần mặc định. Visual Studio khác với Visual Studio Code; chỉ cài VS Code chưa đủ để build app Windows. Xem [thiết lập Windows](https://docs.flutter.dev/platform-integration/windows/setup).
5. Cài [Git for Windows](https://git-scm.com/downloads/win) nếu tải source bằng `git clone`. Nếu tải ZIP ở bước 3 bên dưới, không cần dùng lệnh Git để tải dự án.

**macOS**

1. Cài Flutter SDK cho máy Mac theo [hướng dẫn cài Flutter](https://docs.flutter.dev/install/manual), chọn hệ điều hành macOS.
2. Thêm thư mục `bin` của Flutter vào PATH theo [hướng dẫn PATH cho macOS](https://docs.flutter.dev/install/add-to-path#macos). Với shell Zsh mặc định, nếu SDK ở `~/develop/flutter`, thêm dòng sau vào `~/.zprofile`:

   ```sh
   export PATH="$HOME/develop/flutter/bin:$PATH"
   ```

   Thay đường dẫn theo nơi bạn đặt SDK, sau đó mở lại Terminal và IDE.
3. Cài Xcode, mở Xcode để hoàn tất cài đặt ban đầu. Theo [hướng dẫn thiết lập macOS](https://docs.flutter.dev/platform-integration/macos/setup), cấu hình công cụ dòng lệnh và đọc/chấp nhận giấy phép Xcode:

   ```sh
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   sudo xcodebuild -license
   ```

   Nếu Xcode nằm ở thư mục khác, sửa đường dẫn trong lệnh đầu cho phù hợp.

### 2. Kiểm tra môi trường trước khi tải dự án

Mở PowerShell trên Windows hoặc Terminal trên macOS, chạy:

```sh
flutter --version
flutter doctor -v
flutter devices
```

- `flutter --version` phải hiển thị phiên bản Flutter và Dart. Nếu báo không nhận diện lệnh, kiểm tra lại PATH ở bước 1 và mở lại terminal.
- Trên Windows, xử lý các lỗi liên quan tới Flutter, Windows và **Visual Studio - develop Windows apps** trong kết quả `flutter doctor -v`.
- Trên macOS, xử lý các lỗi liên quan tới Flutter và Xcode. Không cần cài Android Studio hoặc Android SDK chỉ để chạy bản Desktop này.
- `flutter devices` cần có thiết bị nền tảng `windows` hoặc `macos` tương ứng. Nếu chưa có, hoàn tất thiết lập Desktop theo liên kết ở bước 1 rồi kiểm tra lại.

### 3. Tải source và cài các gói phụ thuộc

Nếu đã có Git, chạy tại thư mục bạn muốn lưu dự án:

```sh
git clone https://github.com/hgpenguin/chude03-flutter-isolates.git
cd chude03-flutter-isolates
```

Hoặc mở [repo trên GitHub](https://github.com/hgpenguin/chude03-flutter-isolates), chọn **Code → Download ZIP**, giải nén toàn bộ rồi mở terminal tại thư mục chứa `pubspec.yaml`. Tên thư mục giải nén có thể khác tên repo; không cần tạo thêm thư mục `isolate_demo`.

Tại thư mục chứa `pubspec.yaml`, chạy:

```sh
flutter pub get
```

### 4. Chạy ứng dụng

Giữ terminal tại thư mục chứa `pubspec.yaml`.

**Windows:**

```powershell
flutter run -d windows
```

**macOS:**

```sh
flutter run -d macos
```

Lần build đầu có thể mất vài phút. Khi cửa sổ app mở, chờ trạng thái **Sẵn sàng** rồi làm theo mục **Cách thử** bên dưới. Nhấn `q` trong terminal đang chạy Flutter để kết thúc phiên chạy.

Để kiểm tra source sau khi chỉnh sửa, chạy tại thư mục dự án:

```sh
flutter analyze
flutter test
```

## Cách thử

1. Chờ **Sẵn sàng**. App kiểm tra dung lượng, checksum và giải mã UTF-8 trong worker.
2. Chạy lần lượt **Main Isolate**, **compute**, **Isolate.spawn**. Quan sát vòng quay, thử nút + và so sánh kết quả.
3. Cả ba chế độ phải trả cùng số bản ghi và tổng amount.
4. Bấm **Thử JSON lỗi qua ports**, xem thông báo, sau đó chạy lại một chế độ.

**Nạp lại dataset** sẽ xóa các kết quả đang hiển thị để bắt đầu phiên mới; các file báo cáo đã ghi vẫn được giữ.

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
docs/            kiến trúc và phương pháp đo
```

Giữ `pubspec.yaml`, `pubspec.lock`, `.metadata` và `analysis_options.yaml` khi chuyển source. `build/`, `.dart_tool/` và Flutter SDK được tạo/cài riêng trên máy nhận.

## Tài liệu

- [Kiến trúc, SpawnJob và cách tính FPS/gap](docs/ARCHITECTURE.md)
- [Phương pháp đo và giới hạn](docs/BENCHMARK.md)
- [Kết quả Windows của phiên bản trước refactor](benchmark_results/RESULTS.md)

