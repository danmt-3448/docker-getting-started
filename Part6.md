
# Multi-Container Docker Application with MySQL

## Documentation
For detailed instructions, refer to the [Docker Get Started Workshop](https://docs.docker.com/get-started/workshop/07_multi_container/).

---

## Steps to Set Up and Run

### Step 1: Create a Docker Network
Create a Docker network to allow containers to communicate.
```bash
docker network create todo-app
```

### Step 2: Set Up MySQL Container
Run a MySQL container attached to the `todo-app` network with persistent data storage.

```bash
docker run -d \
    --name mysql-first \
    --network todo-app --network-alias mysql \
    -v todo-mysql-data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=todos \
    mysql:8.0
```

#### Giải Thích Chi Tiết Từng Tùy Chọn:
- **`docker run -d`**: Chạy container ở chế độ nền (background).
- **`--network todo-app`**: Kết nối container vào mạng `todo-app` để các container khác có thể truy cập vào.
- **`--network-alias mysql`**: Thiết lập alias `mysql` trên mạng `todo-app`, cho phép các container khác tham chiếu đến container MySQL này thông qua alias này.
- **`-v todo-mysql-data:/var/lib/mysql`**: Sử dụng một volume tên là `todo-mysql-data` để lưu trữ dữ liệu của MySQL. Điều này giúp dữ liệu không bị mất khi container bị xóa.
- **`-e MYSQL_ROOT_PASSWORD=secret`**: Đặt mật khẩu cho tài khoản root của MySQL.
- **`-e MYSQL_DATABASE=todos`**: Khởi tạo một database mới có tên `todos` khi container chạy lần đầu tiên.
- **`mysql:8.0`**: Sử dụng phiên bản MySQL 8.0.

### Step 3: Access MySQL
Access the MySQL container to verify the database.

1. Mở phiên terminal trong container MySQL:
    ```bash
    docker exec -it <mysql-container-id> mysql -u root -p
    ```

2. Trong MySQL CLI, kiểm tra danh sách databases:
    ```sql
    SHOW DATABASES;
    ```

#### Expected Output:
```plaintext
| Database           |
|--------------------|
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| todos              |
**5 rows in set (0.00 sec)**
```

---

## Connecting to MySQL from Another Container
Use the `netshoot` container to connect to MySQL and test the network setup:

1. Run the `netshoot` container on the `todo-app` network:
    ```bash
    docker run -it --network todo-app nicolaka/netshoot
    ```

2. Inside the container, check connectivity to MySQL using DNS:
    ```bash
    dig mysql
    ```

---

## Run Your Application with MySQL

Start your application container with environment variables for MySQL connection.

```bash
docker run -dp 127.0.0.1:3000:3000 \
  --name run-mysql \
  -w /app -v "$(pwd):/app" \
  --network todo-app \
  -e MYSQL_HOST=mysql \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=secret \
  -e MYSQL_DB=todos \
  node:18-alpine \
  sh -c "yarn install && yarn cache clean && yarn run dev"
```

### Explanation:
- **`127.0.0.1:3000:3000`**: Ánh xạ cổng 3000 trên localhost tới cổng 3000 trong container.
- **`-w /app`**: Thiết lập thư mục làm việc là `/app`.
- **`-v "$(pwd):/app"`**: Gắn thư mục hiện tại vào `/app` trong container.
- **`--network todo-app`**: Kết nối container ứng dụng vào mạng `todo-app` để có thể truy cập MySQL.
- **Các Biến Môi Trường**:
  - `MYSQL_HOST`: Tên alias cho MySQL.
  - `MYSQL_USER`, `MYSQL_PASSWORD`: Thông tin đăng nhập MySQL.
  - `MYSQL_DB`: Tên database (`todos`).
- **`node:18-alpine`**: Sử dụng phiên bản nhẹ của Node.js 18.
- **Lệnh**: Cài đặt các dependencies, xóa cache và chạy ứng dụng ở chế độ phát triển.

### View Logs
Check the application logs to confirm it's working:
```bash
docker logs -f <container-id>
```

---

## Access the `todos` Database in MySQL
```bash
docker exec -it <mysql-container-id> mysql -p todos
```
Lệnh này mở một phiên MySQL trực tiếp (`mysql` là phiên bản), vào database `todos` để kiểm tra thêm.


```bash
select * from todo_items;
```
Lệnh này dùng để check data của table `todo_items`

---
