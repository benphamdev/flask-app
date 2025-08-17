# -------- Stage 1: Build Stage --------
FROM python:3.11-slim AS builder

# Cài các thư viện build cần thiết
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Tạo thư mục làm việc
WORKDIR /app

# Copy requirements và cài đặt vào thư mục riêng
COPY requirements.txt .

# Tạo thư mục chứa các gói cài xong
RUN pip install --upgrade pip && \
    pip install --prefix=/install --no-cache-dir -r requirements.txt

# -------- Stage 2: Runtime Stage --------
FROM python:3.11-slim

# Tạo user không phải root để chạy app
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Tạo thư mục làm việc
WORKDIR /app

# Copy các thư viện đã cài từ builder stage
COPY --from=builder /install /usr/local

# Copy toàn bộ mã nguồn vào container
COPY . .

# Chuyển ownership cho appuser
RUN chown -R appuser:appuser /app

# Chuyển sang user không phải root
USER appuser

# Cổng Flask sử dụng
EXPOSE 5000

# Thiết lập biến môi trường Flask
ENV FLASK_HOST=0.0.0.0
ENV FLASK_PORT=5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

# Khởi động ứng dụng với bind đến tất cả interfaces
CMD ["python", "-c", "import app; app.app.run(host='0.0.0.0', port=5000)"]
