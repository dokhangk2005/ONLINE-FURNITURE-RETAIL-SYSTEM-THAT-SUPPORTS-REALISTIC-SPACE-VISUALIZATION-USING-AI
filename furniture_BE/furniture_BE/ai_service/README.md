# Furniture AI service

## Kiểm thử và tối ưu 2E

Ảnh phòng được thu gọn tối đa 1600 px trước khi suy luận; các ảnh kết quả được mã hóa PNG song song. Backend gắn `ETag` và `Cache-Control` để trình duyệt tái sử dụng ảnh hoặc nhận phản hồi `304 Not Modified`.

Chạy unit test AI trong thư mục `ai_service`:

```powershell
.\.venv\Scripts\python -m unittest -v test_scene_utils.py
```

Chạy kiểm thử tích hợp cache, ảnh phân tích và lưu mask trong thư mục backend:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\verify-visualizer-2e.ps1
```

Dịch vụ Python cung cấp hai nhóm API:

- `POST /remove-background`: xóa nền ảnh sản phẩm bằng `u2netp`.
- `POST /analyze-room`: nhận diện sàn/tường, tạo bản đồ chiều sâu và dữ liệu đặt vật thể 2B.
- `GET /health`: kiểm tra model đã có và đã nạp vào bộ nhớ hay chưa.

Yêu cầu Python 3.11 hoặc 3.12. Chạy trong thư mục `ai_service`:

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install --upgrade pip
.\.venv\Scripts\python -m pip install -r requirements.txt
.\.venv\Scripts\python .\download_models.py
.\run.ps1
```

`download_models.py` tải khoảng 110 MB model ONNX vào thư mục `models/`:

- Depth Anything V2 ViT-S cho chiều sâu tương đối.
- SegFormer B0 ADE20K cho phân vùng ngữ nghĩa sàn và tường.

Metadata 2B gồm tứ giác `floorPlane`, `wallPlane` và `depthGrid` 32×24. Flutter dùng chúng để giữ tâm sản phẩm trong mặt phẳng, nội suy tỷ lệ gần–xa và cho phép hiệu chỉnh phối cảnh bằng bốn góc.

Metadata 2C nằm trong `lighting`: độ sáng nền, nhiệt màu, độ tương phản, vị trí nguồn sáng, hướng/độ mềm bóng và lưới sáng 16×12. Flutter nội suy lưới tại vị trí sản phẩm rồi kết hợp với các tinh chỉnh thủ công của người dùng.

Giai đoạn 2D bổ sung `foreground.png`, `occlusion-mask.png` và tỷ lệ `occlusionCoverage`. Flutter đặt foreground phía trên các sản phẩm cần che, đồng thời lưu các nét xóa/phục hồi mask trong `sceneJson` của thiết kế.

Model ONNX không được đưa vào Git. Backend lưu kết quả phân tích theo từng thiết kế và trả cache ở các lần gọi sau.
