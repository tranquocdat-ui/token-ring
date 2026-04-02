# Tokenring Docker Deployment Guide

## Yêu cầu (Requirements)
- Docker (phiên bản 20.10+)
- Docker Compose (phiên bản 1.29+)
- Git (tuỳ chọn)

## Cài đặt Docker

### Windows / Mac:
Tải và cài đặt [Docker Desktop](https://www.docker.com/products/docker-desktop)

### Linux (Ubuntu/Debian):
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER
```

## Cách sử dụng (Usage)

### 1. Build Docker Image
```bash
bash deploy.sh
# Hoặc:
docker build -t tokenring:latest .
```

### 2. Chạy tất cả các servers (Run all servers with docker-compose)
```bash
docker-compose up -d
```

Kiểm tra status:
```bash
docker-compose ps
```

### 3. Chạy một server riêng (Run specific server)
```bash
# Run Server 1
docker run -d \
  --name tokenring-server1 \
  -e SERVER_NUM=1 \
  -p 5001:5000 \
  tokenring:latest

# Run Server 2
docker run -d \
  --name tokenring-server2 \
  -e SERVER_NUM=2 \
  -p 5002:5000 \
  tokenring:latest
```

### 4. Xem logs (View logs)
```bash
# Xem logs của một server
docker logs -f tokenring-server1

# Xem logs của tất cả servers
docker-compose logs -f
```

### 5. Dừng containers (Stop containers)
```bash
# Dừng tất cả
docker-compose down

# Hoặc dừng riêng từng server
docker stop tokenring-server1
docker stop tokenring-server2
# ...
```

### 6. Dọn dẹp (Clean up)
```bash
# Xóa containers, networks
docker-compose down -v

# Xóa image
docker image rm tokenring:latest
```

## Sử dụng Deploy Script
```bash
bash deploy.sh
```

Script này sẽ hiển thị menu tương tác với các lựa chọn:
1. Build Docker image
2. Run all servers (docker-compose)
3. Run specific server
4. Stop all containers
5. View server logs
6. Clean up

## Cải tiến Dockerfile (Enhancement Tips)

Nếu cần GUI (X11 forwarding) để chạy Swing components:
```bash
docker run -d \
  --name tokenring-server1 \
  -e SERVER_NUM=1 \
  -e DISPLAY=:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -p 5001:5000 \
  tokenring:latest
```

## Troubleshooting

### Docker daemon not running
```bash
# Windows/Mac: Mở Docker Desktop application
# Linux:
sudo systemctl start docker
```

### Permission denied
```bash
sudo usermod -aG docker $USER
# Đăng xuất và đăng nhập lại
```

### Port already in use
Thay đổi port mapping trong `docker-compose.yml` hoặc khi chạy individual container

### Building fails
```bash
docker build --no-cache -t tokenring:latest .
```

## Networking

Các servers có thể giao tiếp với nhau qua mạng `tokenring-network`:
- `tokenring-server1:5000`
- `tokenring-server2:5000`
- `tokenring-server3:5000`
- etc.

Thay đổi cổng localhost mapping nếu cần:
- Server 1: `localhost:5001` → container:5000
- Server 2: `localhost:5002` → container:5000
- ...

## Deployment trên Server

### Sử dụng docker-compose:
```bash
# Clone repository
git clone <repo-url>
cd Tokenring

# Khởi chạy các servers
docker-compose up -d

# Kiểm tra status
docker-compose ps

# Xem logs
docker-compose logs -f
```

### Sử dụng Kubernetes (nếu cần):
Bạn có thể convert docker-compose thành Kubernetes manifests sử dụng `kompose`:
```bash
kompose convert -f docker-compose.yml
```
