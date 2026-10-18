# Yêu cầu Chủ đề 03

Nguồn: đề bài môn học `Chude_LaptrinhDanentang.pdf`, trang 1–3. Hai sinh viên thực hiện Chủ đề 03 — Isolates trong Dart/Flutter.

| Mã | Yêu cầu của đề | Sản phẩm/bằng chứng |
|---|---|---|
| R01 | Nhóm 02 sinh viên, WBS rõ vai trò | TEAM.md: UI, logic, state, Database/API, báo cáo/slide |
| R02 | Single-thread và Multi-thread | Giải thích tác vụ CPU và xử lý giao diện |
| R03 | Vùng nhớ độc lập của Isolate | Sơ đồ luồng dữ liệu, giải thích message passing |
| R04 | SendPort, ReceivePort, compute | Source lib/services/processing.dart và phần trình bày |
| R05 | Demo đo FPS so sánh Main và Isolate | Cùng input/logic; raw data, phương pháp và giới hạn |
| R06 | Parse JSON >15 MB hoặc lọc ảnh độ phân giải cao | Đã chọn JSON: asset, generator, metadata, kết quả |
| R07 | Slide PowerPoint/PDF có kiến trúc, Data Flow, bản chất công nghệ | File slide; tài liệu nội dung ở ARCHITECTURE.md |
| R08 | GitHub/GitLab công khai, README, commit theo thành viên | Repo truy cập được, hướng dẫn dựng/chạy, đóng góp trung thực |
| R09 | Ứng dụng biên dịch và live demo trên thiết bị | Build/chạy Windows hoặc macOS trên máy demo |
| R10 | Báo cáo 20 phút: 10 lý thuyết, 5 demo/code, 5 Q&A | Kịch bản DEMO.md, hai thành viên cùng tham gia |
| R11 | Dart style, ngoại lệ, demo ổn định, UI hoàn thiện | Analyze, test parser/kết quả/lỗi/lifecycle và demo native |
| R12 | Hiểu cơ sở và giải thích được sản phẩm | Mỗi thành viên tự sửa, lần luồng và trả lời vấn đáp |

Thang điểm theo đề: slide/báo cáo 20%; source 30%; demo 30%; thuyết trình/Q&A 20%.

## Phương án triển khai của nhóm

- Chung source Windows/macOS Desktop; đề không yêu cầu riêng Android cho Chủ đề 03.
- JSON cục bộ UTF-8 28.497.671 byte (>15 MiB), 180.000 bản ghi; tổng amount 8.967.430.000.
- Main, compute và Isolate.spawn cùng gọi một parser. Ba nút là lựa chọn minh họa của nhóm, không phải số chế độ bắt buộc của đề.
- Có animation, nút tương tác, UI FPS ước lượng, gap và thời gian xử lý; số liệu không phải FPS màn hình vật lý.
- Database/API: không dùng; input nằm trong asset offline.

## Phần còn cần hoàn tất để nộp

- Xác nhận WBS theo tên hai thành viên trong TEAM.md; mỗi người review và tự commit phần thực tế mình hoàn thiện. Bản đơn giản hóa UI chờ Nhi nhận bản vá và commit theo GIT_HANDOFF.md.
- Làm slide PowerPoint/PDF theo mẫu lớp nếu có.
- Repo công khai: [github.com/hgpenguin/chude03-flutter-isolates](https://github.com/hgpenguin/chude03-flutter-isolates). Thành viên còn lại thử clone và chạy README trên máy của mình.
- Kiểm tra macOS nếu dùng Mac để báo cáo; hiện mới có bằng chứng Windows.
- Đối chiếu phép đo với DevTools; ghi giới hạn lifecycle unknown của môi trường Windows đã đo.
- Tổng duyệt: mỗi thành viên trình bày được luồng xử lý, SpawnJob.run và cách tính FPS/gap.
