# Sử dụng Image Python chính thức phiên bản rút gọn nhẹ
FROM python:3.10-slim

# Cài đặt thêm lệnh curl để Docker thực hiện lệnh HEALTHCHECK thành công
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# Thiết lập thư mục làm việc bên trong container
WORKDIR /app

# Thiết lập biến môi trường ngăn Python ghi file pyc và tối ưu log
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Sao chép file danh sách thư viện vào container trước để tối ưu cache build
COPY requirements.txt .

# Tiến hành cài đặt các thư viện Python cần thiết
RUN pip install --no-cache-dir -r requirements.txt

# Sao chép toàn bộ mã nguồn ứng dụng vào container
COPY . .

# CẤU HÌNH USER NON-ROOT ĐỂ BẢO MẬT TUYỆT ĐỐI
RUN useradd -u 1001 appuser && chown -R appuser:appuser /app
USER appuser

# KHAI BÁO HEALTHCHECK GỌI ĐƯỜNG DẪN /health SỬ DỤNG CURL VỪA CÀI ĐẶT
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Mở cổng 8000 mạng nội bộ của container ra ngoài
EXPOSE 8000

# Lệnh khởi chạy ứng dụng uvicorn server thật
CMD ["uvicorn", "iot_app.main:app", "--app-dir", "src", "--host", "0.0.0.0", "--port", "8000"]
