# Phương pháp đo

## Input và tính công bằng

- transactions-v1, 28.497.671 byte UTF-8, 180.000 bản ghi, amount=(index*37+17)%100000.
- Tổng expected 8.967.430.000; FNV-1a32 5598744f. Dataset.load đọc asset; compute kiểm byte/checksum và giải mã UTF-8 trước khi đo.
- Cùng String, parser/validation/tổng hợp, cùng thiết bị/build mode. Chỉ vị trí thực thi khác nhau.
- Không thêm sleep/vòng lặp giả vào parser để tạo chênh lệch. Không trộn nạp asset hoặc ghi file vào task.

## Số đo

| Trường | Ý nghĩa |
|---|---|
| taskMs | Từ trước lời gọi Main/compute/spawn đến khi nhận kết quả; gồm overhead gọi/truyền/nhận |
| parseMs | Stopwatch trong callback chung: decode + validate + tổng hợp; có ảnh hưởng GC/lập lịch |
| windowMs | Thời gian thực tế của toàn cửa sổ, gồm cả khoảng Main đứng |
| frameCallbacks | Số callback AnimationController trong cửa sổ |
| estimatedUiFps | frameCallbacks / (windowMs/1000); không phải FPS vật lý |
| maxGapMs | Gap lớn nhất giữa callbacks, bao gồm hai biên cửa sổ |
| frameTimestampsUs | Các mốc callback từ cùng Stopwatch để tính lại |
| lifecycleAtStart/End | Trạng thái embedding cung cấp; có thể unknown |
| incomplete | Lỗi, không có callback hoặc đã nhận lifecycle rời resumed |

Không dùng 1000/buildDuration làm FPS. Không bỏ khoảng không có callback do Main đứng khỏi mẫu số. Khi lifecycle unknown, không tự suy ra cửa sổ đang focus; kiểm tra thủ công và công bố điều kiện này.

## Quy trình

1. Chạy profile trên Windows/macOS Desktop; cùng máy cho tất cả modes.
2. Nạp input và kiểm metadata ngoài phép đo.
3. Batch warm-up từng mode, đo không tải 1 mẫu rồi 5 vòng xoay thứ tự Main/compute/spawn.
4. Mỗi cửa sổ mục tiêu 5 giây: khoảng 1 giây trước tác vụ, tiếp tục ít nhất 1 giây sau tác vụ. Task dài làm cửa sổ dài hơn; luôn lưu thời gian thật và timestamps. Timer có sai số lập lịch, không dùng độ dài danh nghĩa để thay mẫu số thật.
5. Giữ animation, cửa sổ hiện/focus và tải nền ổn định. Không log/setState mỗi frame.
6. Kiểm count/tổng với metadata, lưu raw JSON/CSV sau cửa sổ. Báo median/range, loại incomplete có lý do.

Xem ../benchmark_results/RESULTS.md và profile-windows-2026-10-17.json/.csv cho batch đã đo. Không ghép Main Windows với worker Mac. Số Desktop không đại diện Android.

## Kiểm chứng và giới hạn

Tests kiểm mẫu số, gap, hai biên và cửa sổ không callback. Batch Windows lưu sẵn thuộc phiên bản trước refactor và đã được tính lại FPS/gap/kết quả từ timestamps. Cần đo lại bản mới trước khi dùng số liệu để đại diện source hiện tại. Chưa đối chiếu Flutter DevTools/engine FrameTiming; FPS vẫn là proxy. GC, khởi tạo heap, nhiệt độ và tải máy ảnh hưởng kết quả. Baseline hiện có 1 mẫu; mỗi mode có 5 mẫu sau warm-up.

Nguồn: [Flutter profiling](https://docs.flutter.dev/perf/ui-performance), [Ticker](https://api.flutter.dev/flutter/scheduler/Ticker-class.html), [FrameTiming callbacks](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addTimingsCallback.html).
