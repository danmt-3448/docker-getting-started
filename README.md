## Remember run command: colima start

# Getting started

This repository is a sample application for users following the getting started guide at https://docs.docker.com/get-started/.
The application is based on the application from the getting started tutorial at https://github.com/docker/getting-started

# Part 1 2: Containerize an application and update

## Build Docker image from Dockerfile:
```bash
docker build -t getting-started .
```

## Run docker image and bind mount
```bash
docker run -dp 127.0.0.1:3000:3000 \ -w /app --mount type=bind,src="$(pwd)",target=/app \ getting-started
```


# Part 3 Share the application

## Docker image to Docker Hub
* Run command **&#8595;**
```bash
docker push danmt99/getting-started:07-Feb-2025
````
* Result: Have error
```
The push refers to repository [docker.io/docker/getting-started]
An image does not exist locally with the tag: docker/getting-started
```

* Run command **&#8595;** to identify local image
```bash
docker tag your-image-local username-docker-hub/your-repository
```
* Example: (username = danmt99, your-image-local = getting-started, your-repository = getting-started)

```bash
docker push danmt99/getting-started:07-Feb-2025
```

## Access a Docker container

> **`docker exec -it 2cd366beac2b sh`**

# Part 4: Persist the DB

## Create Docker Volume
* Create volume **&#8595;**
```bash
docker volume create todo-db
```

* Run docker with volume  **&#8595;**
```bash
docker run -dp 127.0.0.1:3000:3000 --mount type=volume,src=todo-db,target=/etc/todos getting-started
```


# Part 5: Use bind mounts
## Run docker with bind mounts
```bash
docker run -dp 127.0.0.1:3000:3000 \
-w /app --mount type=bind,src="$(pwd)",target=/app \
node:18-alpine \
sh -c "yarn install && yarn run dev"
```

### Phân tích từng phần
-   **`docker run`**: Khởi chạy một container Docker mới.

-   **`-d`**: Chạy container ở chế độ detached (background).

-   **`-p 127.0.0.1:3000:3000`**: Ánh xạ cổng 3000 trên máy chủ (chỉ localhost) tới cổng 3000 trong container.

    -   `127.0.0.1`: Chỉ cho phép truy cập từ máy chủ.
    -   `3000`: Cổng trên máy chủ.
    -   `3000`: Cổng trong container.

-   **`-w /app`**: Đặt thư mục làm việc bên trong container là `/app`.

-   **`--mount type=bind,src="$(pwd)",target=/app`**: Gắn thư mục hiện tại trên máy chủ vào container tại `/app` (bind mount).

    -   `type=bind`: Kiểu mount là bind mount.
    -   `src="$(pwd)"`: Đường dẫn thư mục hiện tại trên máy chủ.
    -   `target=/app`: Đường dẫn trong container.

-   **`node:18-alpine`**: Sử dụng Docker image `node:18-alpine`.

-   **`sh -c "yarn install && yarn run dev"`**: Lệnh được thực thi bên trong container.

    -   `sh -c`: Chạy lệnh bằng shell `sh`.
    -   `"yarn install && yarn run dev"`: Chuỗi lệnh.
        -   `yarn install`: Cài đặt dependencies.
        -   `&&`: Toán tử AND logic.
        -   `yarn run dev`: Chạy script `dev`.

# Part 6: Multi container apps

## Run docker network
```bash
docker network create todo-app
```
### Phân tích
* Lệnh docker network create todo-app được dùng để tạo một Docker network mới có tên là todo-app.

* Docker network là một tính năng cho phép các container giao tiếp với nhau.  Theo mặc định, các container Docker chạy độc lập và không thể kết nối trực tiếp với nhau trừ khi chúng được kết nối vào cùng một network.


## Run docker mysql
```bash
docker run -d \
--network todo-app --network-alias mysql \
-v todo-mysql-data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=secret \
-e MYSQL_DATABASE=todos \
mysql:8.0
```

### Phân tích từng phần
* **`docker run`**: Lệnh cơ bản để khởi tạo và chạy một container Docker.

* **`-d`**: Chạy container ở chế độ detached (background). Container sẽ chạy ẩn, bạn có thể tiếp tục sử dụng terminal.

* **`--network todo-app`**: Kết nối container này vào network có tên `todo-app`.  Docker network cho phép các container giao tiếp với nhau.  Nếu network `todo-app` chưa tồn tại, bạn cần tạo nó trước.

* **`--network-alias mysql`**: Gán alias (bí danh) `mysql` cho container này trong network `todo-app`.  Các container khác trong cùng network có thể sử dụng bí danh này để kết nối tới container MySQL, ví dụ: `mysql://mysql:3306`.  Việc này giúp đơn giản hóa việc kết nối, không cần dùng địa chỉ IP.

* **`-v todo-mysql-data:/var/lib/mysql`**: Gắn một volume vào container.
    * `todo-mysql-data`: Tên của Docker volume. Nếu volume này chưa tồn tại, Docker sẽ tự động tạo.  Đây là nơi dữ liệu của MySQL sẽ được lưu trữ.  Việc sử dụng volume đảm bảo dữ liệu sẽ không bị mất khi container bị dừng hoặc xóa.
    * `/var/lib/mysql`: Đường dẫn bên trong container, nơi MySQL lưu trữ dữ liệu.  Việc gắn volume vào đây cho phép dữ liệu MySQL tồn tại độc lập với container.

* **`-e MYSQL_ROOT_PASSWORD=secret`**: Đặt biến môi trường (environment variable) `MYSQL_ROOT_PASSWORD` cho container.  Đây là mật khẩu cho tài khoản root của MySQL.  **Cực kỳ quan trọng:** Trong môi trường thực tế, bạn *không bao giờ* nên lưu trữ mật khẩu trong câu lệnh như thế này.  Nên sử dụng các phương pháp an toàn hơn, ví dụ như Docker secrets hoặc biến môi trường được quản lý bên ngoài.  `secret` chỉ là ví dụ minh họa.

* **`-e MYSQL_DATABASE=todos`**: Đặt biến môi trường `MYSQL_DATABASE` cho container.  Biến này chỉ định tên của database sẽ được tạo khi MySQL khởi động.  Trong trường hợp này, database sẽ có tên `todos`.

* **`mysql:8.0`**:  Đây là Docker image được sử dụng.  Nó chỉ định phiên bản MySQL 8.0. Docker sẽ kéo image này về (nếu chưa có sẵn) và sử dụng nó để tạo container.


## Access to docker mysql
```bash
docker exec -it <mysql-container-id> mysql -u <your-sql-name> -p -h localhost
```

* Example: docker exec -it 39e541fc0319 mysql -u root -p -h localhost

## Connect to MySQL
```bash
docker run -it --network todo-app nicolaka/netshoot
```
### Phân tích
Lệnh `docker run -it --network todo-app nicolaka/netshoot` dùng để khởi chạy một container Docker sử dụng image `nicolaka/netshoot` và kết nối nó vào network `todo-app`.  Đây là giải thích chi tiết:

* **`docker run`**: Lệnh cơ bản để khởi tạo và chạy một container Docker mới.

* **`-it`**: Kết hợp của hai option:
    * `-i` (interactive): Giữ STDIN (standard input) mở.  Điều này cho phép bạn tương tác với container, nhập lệnh, v.v.
    * `-t` (tty): Cấp một pseudo-TTY (terminal).  Điều này giúp hiển thị đầu ra từ container một cách chính xác và hỗ trợ các tính năng tương tác.

* **`--network todo-app`**: Kết nối container này vào Docker network có tên `todo-app`.  Như đã giải thích trước đó, Docker network cho phép các container giao tiếp với nhau.  Bằng cách kết nối container `netshoot` vào network `todo-app`, nó có thể giao tiếp với các container khác trong cùng network (ví dụ: container MySQL, container ứng dụng web).

* **`nicolaka/netshoot`**: Đây là Docker image được sử dụng. `nicolaka/netshoot` là một image chứa nhiều công cụ mạng hữu ích (như `ping`, `traceroute`, `tcpdump`, `netstat`, `dig`, `nslookup`, v.v.).  Nó thường được dùng để debug và kiểm tra kết nối mạng bên trong Docker.

## Check IP address
* Run command **&#8595;** inside container to check ip address
```bash
dig mysql
```

## Run your app with MySQL
* Run commad **&#8595;**
```bash
docker run -dp 127.0.0.1:3000:3000 \
  -w /app -v "$(pwd):/app" \
  --network todo-app \
  -e MYSQL_HOST=mysql \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=secret \
  -e MYSQL_DB=todos \
  node:18-alpine \
  sh -c "yarn install && yarn run dev"
```
