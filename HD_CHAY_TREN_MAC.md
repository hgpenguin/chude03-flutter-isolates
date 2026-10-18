# Chạy Isolate Lab trên macOS

## Chuẩn bị

Source đã được kiểm tra bằng Flutter **3.47.7**, Dart **3.13.5** trên Windows. Máy Mac cần Flutter với Dart đáp ứng `^3.13.5` trong pubspec và **Xcode đầy đủ**, đã chọn command-line tools của Xcode. Chỉ cài Command Line Tools riêng lẻ chưa đủ để build Flutter macOS.

Xem [hướng dẫn thiết lập macOS của Flutter](https://docs.flutter.dev/platform-integration/macos/setup). Partner đã có Xcode thì kiểm tra cấu hình trước, không cần cài lại ngay.

## Chạy từ ZIP

Giải nén `ChuDe03_source_macOS.zip`. Nếu thư mục `isolate_demo` nằm trong Downloads, mở Terminal:

```sh
cd "$HOME/Downloads/isolate_demo"
flutter --version
flutter doctor -v
flutter devices
flutter pub get
flutter analyze
flutter test
flutter run -d macos
```

Nếu giải nén ở nơi khác, thay đường dẫn trong lệnh `cd`. Phải chạy lệnh tại thư mục chứa `pubspec.yaml`; `flutter devices` cần thấy thiết bị macOS. JSON và metadata đã có sẵn, không cần tạo lại dữ liệu.

## Lấy source từ GitHub

Trong Terminal, tại thư mục muốn lưu dự án:

```sh
git clone https://github.com/hgpenguin/chude03-flutter-isolates.git
cd chude03-flutter-isolates
flutter pub get
flutter run -d macos
```

Các bước kiểm tra và lấy số liệu giống bản ZIP.

## Đo và lưu kết quả

Tại cùng thư mục trong Terminal:

```sh
flutter run --profile -d macos
```

Đợi **Sẵn sàng**, bấm lần lượt **Main Isolate**, **compute**, **Isolate.spawn**. Mỗi nút tạo một mẫu đo; không có warm-up hoặc đo không tải. Quan sát vòng quay và thử nút +. Ba chế độ phải trả 180.000 bản ghi, tổng amount 8.967.430.000. Thử thêm **Thử JSON lỗi qua ports** rồi chạy lại một chế độ để kiểm tra phục hồi.

Kết quả nằm ở `benchmark_results/runs-…/report.json` và `report.csv` dưới thư mục làm việc của app. Đường dẫn chính xác hiện trên màn hình. Có thể chỉ định nơi ghi trong Terminal:

```sh
flutter run --profile -d macos --dart-define=BENCHMARK_OUTPUT="$HOME/Downloads/isolate-results"
```

Cấu hình runner hiện tắt App Sandbox để bản Desktop dùng cho buổi demo có thể ghi báo cáo ra đường dẫn đã chọn. Cấu hình này dành cho chạy local, chưa phải cấu hình phát hành qua Mac App Store.

Đo tất cả chế độ trên cùng Mac và cùng build mode. UI FPS là số callback mỗi giây, không phải FPS màn hình vật lý. Giữ cửa sổ hiện/focus khi đo, kiểm tra cờ `incomplete` trước khi dùng kết quả. Nếu lifecycle đầu cửa sổ khác `resumed` hoặc chuyển khỏi `resumed` trong lúc đo, app sẽ đánh dấu mẫu chưa đủ.

## Trạng thái kiểm tra

Windows: analyze sạch, 31 test pass, build và chạy profile thành công sau refactor. macOS: **chưa build/chạy thực tế**; cần ghi nhận kết quả trên máy Mac trước báo cáo.
