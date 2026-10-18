# Kịch bản báo cáo

## 10 phút lý thuyết và kiến trúc

1. Bài toán CPU ảnh hưởng UI và input/output của app — 1 phút.
2. Single-thread/Multi-thread, Main Isolate, event loop, CPU/I/O và async — 2 phút.
3. Bộ nhớ Isolate độc lập, SendPort/ReceivePort, message passing — 2 phút.
4. compute/spawn, kiến trúc và Data Flow — 2 phút.
5. Phép đo công bằng, số liệu thật, giới hạn và WBS — 3 phút.

Nội dung kiến trúc: ARCHITECTURE.md. Cần chuyển nội dung sang slide PowerPoint/PDF theo yêu cầu lớp; file slide hiện chưa có.

## 5 phút demo và code

| Thời gian | Thao tác |
|---|---|
| 0:00–0:40 | Xem JSON 27,18 MiB, byte/checksum/count và expected total |
| 0:40–1:20 | Chạy Main, nhìn animation/thử nút + |
| 1:20–2:10 | Chạy compute rồi spawn, kiểm kết quả giống nhau |
| 2:10–3:00 | Đọc task ms, UI FPS ước lượng và max gap; nêu overhead/giới hạn |
| 3:00–4:10 | Chỉ parser chung, compute, jsonWorker/ports và chỗ controller notifyListeners |
| 4:10–5:00 | Thử JSON lỗi qua ports, chạy lại, chỉ raw JSON/CSV |

Nếu cần số liệu chuẩn bị cho slide, chạy thủ công từng chế độ trước giờ demo và lưu báo cáo. Trong buổi demo, mỗi chế độ chỉ cần một lần để minh họa; không có warm-up, đo không tải hoặc batch tự động. Tổng duyệt có bấm giờ trên đúng máy báo cáo.

## 5 phút Q&A

| Câu hỏi | Ý chính |
|---|---|
| async có tự chuyển CPU sang worker? | Không; cần API giao việc cho Isolate |
| Worker có sửa UI trực tiếp? | Trả message; Main cập nhật State |
| SendPort/ReceivePort làm gì? | Đầu gửi / nhận và listen; không chia sẻ vùng nhớ mutable |
| Vì sao worker có thể lâu hơn? | Khởi tạo, truyền/nhận, heap/GC/lập lịch; phân biệt taskMs và parseMs |
| FPS có bỏ khoảng Main đứng? | Stopwatch vẫn chạy; mẫu số toàn cửa sổ, gap gồm hai biên |
| Có phải FPS vật lý? | Không, callback UI là proxy; còn cần đối chiếu DevTools |
| Worker lỗi hoặc thoát sớm? | WorkerDataError/WorkerFailure, onError/onExit, timeout và cleanup |
| Dispose khi compute chưa xong? | controller bỏ kết quả sau dispose; không tuyên bố kill compute |
| Input có tái tạo được? | Generator cố định và metadata byte/checksum/count/tổng |

Hai thành viên cần giải thích toàn luồng và phần do người kia phụ trách; tên và phân công ở ../TEAM.md.
