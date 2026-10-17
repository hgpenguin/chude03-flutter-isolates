# Kết quả profile Desktop

Ngày 17/10/2026, một máy Windows; cửa sổ native đã được mở, quan sát và bấm batch. Đây là phép đo callback UI sơ bộ, chưa phải số FPS vật lý hoặc phép đo đã đối chiếu DevTools. Baseline chỉ có 1 mẫu; mỗi mode có 5 mẫu sau warm-up, luân phiên thứ tự. Batch này thuộc phiên bản trước refactor ngày 17/10/2026. Bản mới đã đổi kiểu kết quả, message worker, controller và cách nạp dữ liệu; bảng này chỉ dùng tham khảo, cần đo lại để báo cáo hiệu năng bản mới.

Raw data: `benchmark_results/profile-windows-2026-10-17.json`

Môi trường: `{"os":"\"Windows 10 Home Single Language\" 10.0 (Build 26200)","processors":4,"dart":"3.13.5 (stable) (Tue Sep 29 01:00:52 2026 -0700) on \"windows_x64\"","flutter":"3.47.7","buildMode":"profile","displayRefreshRateHz":60.0,"cpuRamAndConditions":"Intel Core i3-1115G4; 2C4T; RAM 7.73 GiB; visible window manually checked; normal background load; lifecycle unknown; no DevTools validation"}`

Dataset: `{"id":"transactions-v1","rule":"180000 rows; amount=(zeroBasedIndex*37+17)%100000","bytes":28497671,"count":180000,"totalAmount":8967430000,"fnv1a32":"5598744f","encoding":"UTF-8"}`

| Chế độ | n hợp lệ | Task ms median [min–max] | UI FPS ≈ median [min–max] | Gap ms median [min–max] |
|---|---:|---|---|---|
| baseline | 1 | — | 59.99 [59.99–59.99] | 26.33 [26.33–26.33] |
| main | 5 | 460.14 [358.20–564.78] | 53.60 [48.38–54.40] | 470.80 [369.48–569.75] |
| compute | 5 | 1382.73 [1196.47–1431.95] | 54.20 [53.80–57.60] | 72.20 [57.70–104.06] |
| spawn | 5 | 1364.80 [1244.03–1497.12] | 55.78 [54.60–58.39] | 62.24 [46.20–78.89] |

Mẫu chưa đủ/lỗi: 0.

Trong batch này, Main có task ngắn hơn nhưng khoảng khựng dài hơn rõ rệt. Worker không tăng tốc tổng thời gian trên máy này. Không suy nguyên nhân chênh lệch toàn bộ là truyền dữ liệu: parseMs cũng chịu GC/khởi tạo heap/lập lịch CPU. UI FPS trung bình toàn cửa sổ có thể che mức khó chịu của một khoảng đứng dài, vì vậy phải đọc cả maxGapMs.

Kiểm toán độc lập bằng PowerShell từ raw timestamps: 16/16 rows khớp frameCallbacks/window, gap lớn nhất gồm hai biên và count/tổng metadata. VM Service sau batch chỉ còn main isolate, không còn json worker. Chỉ batch chính đi kèm được dùng cho bảng này.

AnimationController listener; monotonic Stopwatch; >=5s window, task at >=1s, >=1s after task; edge gaps included; batch warms all modes then 5 rotated rounds. UI callbacks are a proxy.

Giới hạn: Không đo frame vật lý; chưa đối chiếu DevTools/FrameTiming. Không so chéo thiết bị/build mode. GC, tải nền, nhiệt độ có ảnh hưởng. incomplete=true khi nhận lifecycle rời resumed, không có callback hoặc lỗi. lifecycle unknown nghĩa embedding không cung cấp trạng thái; cần kiểm tra thủ công cửa sổ hiện/focus và điều kiện tải.
