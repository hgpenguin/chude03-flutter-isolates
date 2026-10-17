# Kiến trúc và luồng dữ liệu

App đọc một file JSON lớn, đếm số bản ghi và cộng `amount`. Ba chế độ chạy cùng một hàm xử lý. Khi chạy trên Main, tác vụ CPU có thể chặn giao diện; khi chạy trong worker, Main có thể tiếp tục vẽ vòng quay và nhận thao tác.

## Nhiệm vụ

| Thư mục | Nhiệm vụ |
|---|---|
| `lib/screens/` | Ghép màn hình, quản lý animation và sao chép clipboard |
| `lib/widgets/` | Các panel dữ liệu, tương tác, nút chạy và kết quả |
| `lib/controllers/` | Trạng thái, khóa nút chạy, warm-up, cửa sổ đo và lifecycle |
| `lib/models/` | Kiểu dữ liệu: summary, kết quả chạy, metadata, báo cáo và message worker |
| `lib/services/` | Nạp dataset, parse JSON, chạy Isolate, tính metrics và ghi file |

`BenchmarkController` dùng `ChangeNotifier`. Khi trạng thái hoặc kết quả thay đổi, controller gọi `notifyListeners()`; `ListenableBuilder` dựng lại giao diện. Controller không giữ widget, `BuildContext` hoặc animation. Callback animation chỉ gửi mốc thời gian vào controller, không yêu cầu dựng lại cả màn hình mỗi frame.

```mermaid
flowchart TD
  A[Main: rootBundle đọc bytes và metadata] --> B[compute: kiểm checksum và giải mã UTF-8]
  B --> C[Dataset sẵn sàng trên Main]
  C --> D[BenchmarkController mở cửa sổ đo]
  D --> E{Chọn chế độ}
  E --> F[Main: parseTimed]
  E --> G[compute: parseTimed trong worker]
  E --> H[spawn: WorkerRequest tới jsonWorker]
  H --> I[WorkerSuccess hoặc lỗi qua ReceivePort]
  F --> J[TaskResult: summary và thời gian]
  G --> J
  I --> J
  J --> K[Đối chiếu metadata, tạo RunRecord]
  L[Animation callbacks và Stopwatch] --> K
  K --> M[Thông báo UI cập nhật]
  K --> N[BenchmarkReport → ReportWriter → JSON và CSV]
```

## Kiểu dữ liệu

- `ParseSummary`: `count`, `totalAmount`. Cả ba chế độ phải trả kết quả bằng nhau.
- `ParseResult`: summary và thời gian bên trong parser. `TaskResult` thêm thời gian toàn lời gọi.
- `RunRecord`: một lần đo, gồm chế độ, thời gian, metrics, lifecycle và lỗi nếu có.
- `WorkerRequest`: chuỗi JSON và `SendPort` trả lời.
- `WorkerMessage`: sealed class với `WorkerSuccess`, `WorkerDataError`, `WorkerFailure`.

Map được dùng ở ranh giới JSON: `jsonDecode`, kiểm tra trường đầu vào và `toJson`. Các lớp xử lý, controller và UI đọc thuộc tính có kiểu, không tra key chuỗi. Không tạo thêm 180.000 object nghiệp vụ vì app chỉ cần đếm và cộng tổng.

## SpawnJob.run hoạt động thế nào?

1. Tạo `ReceivePort` và đăng ký listener trước khi spawn. `Completer<ParseResult>` cung cấp Future để Main chờ kết quả.
2. Tạo timeout 60 giây, gọi `Isolate.spawn` với `WorkerRequest`. Chỉ gửi dữ liệu, không gửi controller hay UI.
3. Worker gọi parser. Thành công gửi `WorkerSuccess`; JSON sai gửi `WorkerDataError`; lỗi khác gửi `WorkerFailure` kèm tên kiểu và stack trace.
4. Main xử lý message bằng `switch`. Chỉ `WorkerDataError` trở thành `FormatException`; lỗi xử lý khác thành `RemoteWorkerException`.
5. `onError` nhận lỗi chưa được worker bắt; VM gửi chuỗi lỗi và stack, nên tên loại được ghi là `uncaught`. `onExit` trả null nếu worker kết thúc mà chưa có kết quả.
6. Future hoàn tất hoặc lỗi đều đi qua `finally`: hủy timer, subscription, đóng port và kill worker. Nếu đóng màn hình trước khi spawn hoàn tất, worker vừa tạo cũng được kill.

Các thông báo dùng chung một port để xử lý kết quả trước thông báo thoát. Mỗi `SpawnJob` chỉ chạy một lần. `compute` không có thao tác kill trực tiếp trong app; controller bỏ kết quả đến sau dispose.

## Chuẩn bị dữ liệu và đo

`rootBundle` đọc asset trên Main. `prepareDataset` chạy trong `compute` để tính checksum và giải mã 28 MB UTF-8. Việc này hoàn tất trước khi cho chạy benchmark. Đọc asset, chuyển dữ liệu giữa isolate và cấp phát vẫn có chi phí; không coi đó là thời gian parse được đo.

`FrameMetrics` ghi thời điểm callback bằng cùng một Stopwatch. `estimatedUiFps = số callback / số giây thực tế`. Ví dụ cửa sổ 5 giây nhận 250 callback thì kết quả là 50 callback/giây, kể cả một đoạn UI đứng trong 5 giây đó.

`maxGapMs` lấy khoảng cách lớn nhất từ đầu cửa sổ đến callback đầu, giữa hai callback liên tiếp, và từ callback cuối đến cuối cửa sổ. Nếu không có callback, gap bằng cả cửa sổ. Đây là cách thấy một lần khựng dài mà FPS trung bình có thể che khuất.

Chi tiết phép đo: [BENCHMARK.md](BENCHMARK.md). UI FPS là nhịp callback, chưa được đối chiếu với DevTools/FrameTiming.

Nguồn: [compute](https://api.flutter.dev/flutter/foundation/compute.html), [gửi message giữa isolate](https://api.dart.dev/dart-isolate/SendPort/send.html).
