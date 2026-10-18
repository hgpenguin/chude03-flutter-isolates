# Bàn giao Git — đơn giản hóa demo Isolate

## Trạng thái bàn giao ngày 18/10/2026

Nhánh làm việc: **`refactor/simplify-isolate-demo`**.

Hoàng commit tài liệu/phân công lên nhánh này. Mã sửa UI/controller/đo hiệu năng được chuẩn bị riêng trong **`nhi-ui.patch`** để Nhi kiểm tra, hoàn thiện và tự commit. Khi nhánh mới chỉ có commit tài liệu của Hoàng, source trên GitHub vẫn còn các nút cũ; chỉ sau khi Nhi áp dụng và commit bản vá thì source và tài liệu mới thống nhất.

Trên máy Windows của Hoàng, bản vá đã được áp dụng trong working tree để kiểm thử, nhưng phần mã này chưa được commit. Không áp dụng bản vá lần nữa trên working tree đó. Trên máy Nhi, tải nhánh và áp dụng bản vá vào checkout sạch như hướng dẫn bên dưới.

## 1. Phân chia phần thay đổi lần này

| Thành viên tự commit | File | Nội dung |
|---|---|---|
| Nguyễn Thái Hoàng | `README.md`, `TEAM.md`, `HD_CHAY_TREN_MAC.md`, `docs/ARCHITECTURE.md`, `docs/DEMO.md`, `docs/REQUIREMENTS.md`, `docs/PHAN_VIEC_A.md`, tài liệu bàn giao này | Cập nhật cách chạy, phân công theo tên và tỷ lệ 50%/50%, đối chiếu yêu cầu, ghi kết quả kiểm tra và cách bàn giao. |
| Lê Trương Uyển Nhi, sau khi nhận và review bản vá | `lib/controllers/benchmark_controller.dart`, `lib/screens/benchmark_page.dart`, `lib/widgets/run_controls_panel.dart`, `lib/widgets/results_panel.dart` | Bỏ hai nút và luồng warm-up/không tải; mỗi lần chạy chọn một chế độ; giữ thử JSON lỗi, tiến độ/Hủy và khóa thao tác khi đang chạy. |
| Lê Trương Uyển Nhi, cùng commit trên | `lib/models/run_record.dart`, `lib/models/benchmark_report.dart`, `tool/summarize_benchmark.dart`, `test/benchmark_controller_test.dart`, `test/benchmark_page_test.dart`, `docs/BENCHMARK.md` | Bản ghi mới chỉ có main/compute/spawn; cập nhật mô tả phép đo và tổng hợp; điều chỉnh test và quy trình lấy số liệu. |

Parser, dataset, processing, frame metrics và report writer không cần sửa chức năng trong lần giản lược này. Không sửa file chỉ để tạo thêm commit. Phân công lâu dài xem [TEAM.md](../TEAM.md); lịch sử tiến độ/Hủy cũ vẫn giữ đúng tác giả đã ghi trên GitHub.

## 2. Nhi nhận bản vá và tự commit

Hoàng chuyển gói bàn giao `ban_giao_git_2026-10-18.zip` cho Nhi bằng kênh nhóm đang dùng. Giải nén để lấy `nhi-ui.patch`. Không có thao tác gửi tin nhắn tự động từ dự án.

Trên máy Nhi, trong repo không có thay đổi chưa lưu:

```sh
git fetch origin
git switch --track origin/refactor/simplify-isolate-demo
git status --short
```

Nếu đã có nhánh local cùng tên, dùng `git switch refactor/simplify-isolate-demo` rồi `git pull --ff-only` thay cho lệnh tạo nhánh. Bảo toàn mọi thay đổi đang làm trước khi chuyển nhánh.

Xác nhận tác giả commit trên chính máy Nhi:

```sh
git config --get user.name
git config --get user.email
```

Nếu chưa đúng tài khoản của Nhi, Nhi tự cấu hình trong repo:

```sh
git config user.name "Lê Trương Uyển Nhi"
git config user.email "ltuyennhi11b1@gmail.com"
```

Thay `/duong-dan/nhi-ui.patch` bằng đường dẫn tới file vừa giải nén, giữ dấu ngoặc kép nếu có khoảng trắng:

```sh
git apply --check "/duong-dan/nhi-ui.patch"
git apply "/duong-dan/nhi-ui.patch"
git diff --check
git diff
flutter analyze
flutter test
```

Trên Mac, kiểm tra thêm `flutter run -d macos`: chạy ba chế độ, thử JSON lỗi và chạy lại; thử tiến độ/Hủy khi worker đang hoạt động. Nếu lấy số liệu, chạy profile và đo trên cùng máy. Nhi cần đọc, hiểu và hoàn thiện phần được bàn giao trước khi tự xác nhận commit.

Sau khi đã kiểm tra:

```sh
git add lib/controllers/benchmark_controller.dart lib/screens/benchmark_page.dart lib/widgets/run_controls_panel.dart lib/widgets/results_panel.dart lib/models/run_record.dart lib/models/benchmark_report.dart tool/summarize_benchmark.dart test/benchmark_controller_test.dart test/benchmark_page_test.dart docs/BENCHMARK.md
git diff --cached --stat
git diff --cached --check
git commit -m "refactor(ui): simplify isolate demo to three modes and error handling"
git push origin refactor/simplify-isolate-demo
```

Nhi cập nhật hàng đóng góp thực tế trong TEAM.md bằng mã commit vừa tạo và kết quả kiểm tra trên máy mình, rồi commit cập nhật đó. Không đánh dấu macOS/demo hoàn tất khi chưa chạy.

## 3. Đưa vào main sau khi hai thành viên hoàn tất

Mở pull request từ `refactor/simplify-isolate-demo` vào `main`, xem lại diff và merge sau khi có commit mã nguồn của Nhi. Chọn **Create a merge commit** để giữ riêng các commit của hai người; không squash gộp mất các commit cá nhân.

Sau khi merge, mỗi máy chạy:

```sh
git switch main
git pull --ff-only origin main
git log --format="%h %an <%ae> %s" -10
```

Giữ lịch sử đã công khai. Các commit cũ phản ánh thời điểm nhập source chung; bản phân công 50%/50% không phải lý do để sửa lại tác giả hoặc tạo commit rỗng. Giáo viên xem phần thay đổi và đóng góp thực tế của từng người qua commit mới, bảng phân công và phần giải thích khi báo cáo.

## 4. Kiểm tra bản vá trên Windows

Ngày 18/10/2026: format hoàn tất, `flutter analyze` không báo lỗi/cảnh báo và toàn bộ **34 test pass** trên working tree đã áp dụng bản vá. `flutter build windows --profile` thành công. Widget test xác nhận panel còn ba chế độ và thử JSON lỗi, không có hai nút cũ. Kiểm thử worker vẫn bao gồm tiến độ, hủy, lỗi, timeout và cleanup. Công cụ tổng hợp đã đọc được báo cáo cũ và chỉ in ba dòng main/compute/spawn; số liệu lịch sử không đại diện cho bản mới. Bản mới chưa được thao tác demo hoặc đo lại trên Windows/macOS.
