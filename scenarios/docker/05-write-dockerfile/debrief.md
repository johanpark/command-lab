# 해설

```dockerfile
FROM busybox
COPY . /www
CMD ["httpd", "-f", "-p", "80", "-h", "/www"]
```
```bash
cd ~/hello-site
docker build -t hello-site:1.0 .
docker run -d --name site -p 8081:80 hello-site:1.0
curl http://localhost:8081/about.html
```

## 함정 포인트
- **`-f` (foreground)**: 컨테이너는 **CMD 프로세스가 끝나면 같이 종료**돼요. 서버 프로그램이 스스로 백그라운드로 숨어 버리면 컨테이너는 "할 일이 끝났다"고 보고 바로 Exited 가 됩니다. 컨테이너 안의 프로그램은 항상 앞에서 실행!
- **빌드 컨텍스트 `.`**: `docker build` 끝의 `.` 은 "이 폴더를 재료로"라는 뜻이에요. COPY 는 이 폴더 **안의** 파일만 쓸 수 있어요.
- **CMD 의 두 형태**: `CMD ["httpd", "-f"]` (exec 형태, 권장) vs `CMD httpd -f` (셸 형태, `sh -c` 로 감싸져서 신호 전달이 어긋날 수 있음)

## 실제 웹 서버라면
```dockerfile
FROM nginx:1.27-alpine
COPY . /usr/share/nginx/html
```
nginx 이미지는 CMD 가 이미 들어 있어서 두 줄이면 끝나요.

## 이미지를 고친 뒤 다시 배포
```bash
docker build -t hello-site:1.1 .
docker rm -f site
docker run -d --name site -p 8081:80 hello-site:1.1
```
