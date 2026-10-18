# Phân công nhóm 02 sinh viên — Chủ đề 03

Thành viên A: **Nguyễn Thái Hoàng** — Git `hgpenguin`, email `thaihoangh216@gmail.com`.

Thành viên B: **Lê Trương Uyển Nhi** — email Git theo lịch sử repo `ltuyennhi11b1@gmail.com`.

Tỷ lệ phân công theo bảng của nhóm: **Hoàng 50%, Nhi 50%**. Đây là tỷ lệ công việc được giao, không suy ra từ số commit hoặc số dòng code.

Phân công theo hai mảng: **A phụ trách dữ liệu và xử lý Isolate; B phụ trách giao diện và đo hiệu năng**. Dự kiến A dùng Windows, B dùng Mac; đổi lại nếu thiết bị thực tế khác. Vai trò không phụ thuộc hệ điều hành.

Bảng dưới phân công rà soát, hoàn thiện, kiểm thử và trình bày. Ghi phần đã làm cùng commit vào bảng đóng góp ở cuối.

## 1. Công việc và sản phẩm bàn giao

| Hạng mục | Người chính | Người review | Công việc và đầu ra cần đạt |
|---|---|---|---|
| Dữ liệu và business logic | A | B | Rà soát `lib/services/dataset.dart`, `lib/services/json_parser.dart`, `tool/generate_dataset.dart`; tái tạo JSON/metadata, kiểm byte/checksum/count/tổng, xử lý JSON sai cấu trúc. |
| Main / compute / spawn và ports | A | B | Rà soát `lib/services/processing.dart`; giải thích parser chung, input/output, SendPort/ReceivePort; kiểm lỗi, timeout, worker thoát sớm và cleanup. |
| Kiểm thử dữ liệu và xử lý | A | B | Chịu trách nhiệm `test/dataset_test.dart`, `test/json_parser_test.dart`, `test/compute_parser_test.dart`, `test/processing_test.dart`; xác nhận các mode cùng kết quả và các ca lỗi được xử lý. Chỉ bổ sung test khi còn thiếu tình huống có ý nghĩa. |
| Tiến độ và hủy worker | A | B | Hoàng phụ trách giao thức WorkerProgress và SpawnJob.cancel, test logic; Nhi tích hợp thanh tiến độ/nút Hủy trong UI và controller. Các commit lịch sử giữ nguyên tác giả thực tế. |
| UI Design, animation và tương tác | B | A | Rà soát `lib/main.dart`, `lib/screens/benchmark_page.dart`, `lib/widgets/`; kiểm bố cục, nút chọn mode, animation, nút +, thông báo kết quả/lỗi và khả năng thao tác khi demo. |
| State Management và lifecycle | B | A | Rà soát `lib/controllers/benchmark_controller.dart`; kiểm nạp dữ liệu → sẵn sàng → đang chạy → thành công/lỗi; chặn chạy trùng; kiểm mounted/dispose và khả năng chạy lại sau lỗi. Phối hợp A tại chỗ hủy worker. |
| Metrics và tổng hợp benchmark | B | A | Rà soát `lib/services/frame_metrics.dart`, `tool/summarize_benchmark.dart`; kiểm cửa sổ đo, FPS callback, max gap hai biên, taskMs/parseMs, `lib/services/report_writer.dart`, xuất JSON/CSV và bảng tổng hợp. |
| Kiểm thử giao diện và metrics | B | A | Chịu trách nhiệm `test/benchmark_page_test.dart`, `test/benchmark_controller_test.dart`, `test/frame_metrics_test.dart`, `test/report_writer_test.dart`; kiểm bằng test hiện có và thao tác thực tế trên cửa sổ app. |
| Kiến trúc và hướng dẫn chạy | A | B | Hoàn thiện `docs/ARCHITECTURE.md` và `README.md`: kiến trúc/Data Flow, cách dựng/chạy, yêu cầu môi trường, kết quả và giới hạn đã kiểm chứng. |
| Phương pháp đo và kết quả | B | A | Hoàn thiện `docs/BENCHMARK.md`, `benchmark_results/RESULTS.md`; lưu raw JSON/CSV, ghi máy/build/dataset, đối chiếu DevTools trên máy đo và nêu giới hạn còn lại. |
| Repo và bàn giao source | A | B | Tạo repo công khai theo yêu cầu đề, kiểm file đưa vào repo và hướng dẫn clone. B thử clone source sạch, chạy theo README và phản hồi lỗi cho A. Mỗi người tự commit phần mình bằng tài khoản thật. |
| Slide và kịch bản báo cáo | B tổng hợp; A viết phần xử lý | Review chéo | A viết phần lý thuyết Isolate, parser, compute/spawn/ports; B viết phần UI/state, kiến trúc ứng dụng, phép đo và kết quả. B thống nhất bố cục, xuất PowerPoint/PDF; cập nhật `docs/DEMO.md` theo kịch bản hai người đã tập. |
| Database/API | Không triển khai | Cả hai | Giải thích app dùng JSON asset offline; không cần bổ sung database hoặc API mạng. |

**Ranh giới sửa file:** A chủ trì dữ liệu/parser/processing, B chủ trì UI/metrics. Khi cần sửa file của nhau, thống nhất trước nội dung và để người phụ trách review; đặc biệt tại giao tiếp `processing.dart` ↔ `benchmark_controller.dart`. A thống nhất với B cấu trúc kết quả/lỗi trước khi hai bên sửa luồng xử lý.

## 2. Công việc chung và thứ tự hoàn tất

1. **Chốt đầu việc:** điền tên, xác nhận máy demo, đọc toàn luồng và thống nhất input/output giữa phần xử lý và UI.
2. **Rà soát song song:** A xử lý dữ liệu/worker/test tương ứng; B xử lý UI/state/metrics/test tương ứng. Mỗi người ghi lỗi phát hiện và phần đã sửa để người kia review.
3. **Tích hợp và kiểm chứng:** chạy `flutter analyze`, `flutter test`, dựng/chạy trên máy demo; thử đủ Main, compute, spawn, JSON lỗi và chạy lại. Mỗi máy dùng để lấy số liệu phải có bộ đo riêng đủ mode với cùng dataset/build mode; không trộn kết quả các máy thành một phép so sánh. B thử clone sạch sau khi A chuẩn bị repo.
4. **Hoàn tất báo cáo:** A chốt phần giải thích xử lý; B chốt biểu đồ/bảng số liệu và file slide. Cả hai tổng duyệt đủ 20 phút, kiểm demo offline và chuẩn bị sẵn raw data trước giờ báo cáo.

Nếu dùng Mac để demo hoặc đưa số liệu Mac vào báo cáo, B phải xác nhận build/chạy và đo trên Mac. Hiện tài liệu mới ghi nhận kiểm tra Windows; không đánh dấu Mac hoàn tất khi chưa chạy thực tế.

## 3. Chia phần trình bày 20 phút

| Phần | A | B |
|---|---|---|
| Lý thuyết và kiến trúc — 10 phút | 5 phút: single-thread/multi-thread, CPU/I/O và async, bộ nhớ độc lập, parser, compute/spawn và ports. | 5 phút: kiến trúc/Data Flow ứng dụng, UI/state, cách đo, kết quả, overhead và giới hạn. |
| Demo và code — 5 phút | 2 phút: chỉ parser và luồng ports trong code; demo JSON lỗi, phục hồi và chỗ nhận kết quả. | 3 phút: giới thiệu dataset, chạy Main/compute/spawn, thao tác animation/nút + và đọc số liệu. |
| Q&A — 5 phút | Chủ trì câu hỏi parser, async, Isolate, ports, lỗi/timeout/cleanup. | Chủ trì câu hỏi UI/lifecycle, FPS/gap, tính công bằng của benchmark. |

Cả hai cần trả lời được toàn luồng, giải thích phần do người kia phụ trách và thay nhau thao tác demo. Chuẩn bị số liệu trước bằng cách chạy thủ công từng chế độ; bản đơn giản hóa bỏ warm-up và đo không tải.

## 4. Ghi nhận đóng góp thực tế

| Thành viên | Việc thực tế đã làm | Ngày hoàn thành | Commit / bằng chứng | Người review và kết quả |
|---|---|---|---|---|
| A — Nguyễn Thái Hoàng | Rà soát dữ liệu/parser/Isolate và test tương ứng; lập [bản đối chiếu phần A](docs/PHAN_VIEC_A.md). Cập nhật tài liệu/phân công và chuẩn bị bàn giao bản đơn giản hóa UI cho Nhi. | 18/10/2026 | Mã ban đầu: [8f1ce1d](https://github.com/hgpenguin/chude03-flutter-isolates/commit/8f1ce1d9d31ce2a27f027ab8a3a6a0b5bde20cc6); tài liệu phần A: [d70d0a7](https://github.com/hgpenguin/chude03-flutter-isolates/commit/d70d0a7ed1c7907b2cb4c98b613114af20ed95f7). Lần cập nhật tài liệu tiếp theo nằm trên nhánh `refactor/simplify-isolate-demo`. | Chưa có xác nhận review chéo. |
| B — Lê Trương Uyển Nhi | Lịch sử repo đã có các bổ sung worker, test, UI và tài liệu tiến độ/Hủy. Đã tiếp nhận, rà soát và áp dụng bản đơn giản hóa UI/controller/đo hiệu năng (3 chế độ Main/Compute/Spawn, xử lý lỗi JSON, tiến độ và hủy). | Commit cũ: 17/10/2026; bản đơn giản hóa: 18/10/2026 | Commit cũ: [30b2428](https://github.com/hgpenguin/chude03-flutter-isolates/commit/30b2428), [7a3e32c](https://github.com/hgpenguin/chude03-flutter-isolates/commit/7a3e32c), [f8a812f](https://github.com/hgpenguin/chude03-flutter-isolates/commit/f8a812f), [1df1617](https://github.com/hgpenguin/chude03-flutter-isolates/commit/1df1617); Đơn giản hóa UI: [e82dfd9](https://github.com/hgpenguin/chude03-flutter-isolates/commit/e82dfd9). | Đã áp dụng bản vá và commit trên nhánh `refactor/simplify-isolate-demo`; sẵn sàng mở PR vào main. |

Cập nhật bảng sau mỗi phần hoàn thành; mỗi người commit bằng tài khoản của mình. Trước khi nộp, kiểm tra link repo, slide, chạy trên máy demo và thử lại README từ source sạch.
