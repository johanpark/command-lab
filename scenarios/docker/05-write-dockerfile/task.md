# Dockerfile 직접 써서 배포하기

`~/hello-site` 에 회사 소개 페이지(`index.html`, `about.html`, `css/`)가 있습니다. 이걸 **이미지로 만들어** 배포해 봅시다.

## 목표
1. `~/hello-site/Dockerfile` 을 작성하세요.
   - 베이스 이미지: `busybox`
   - 사이트 파일 전부를 이미지 안의 **`/www`** 에 복사
   - 시작 명령: `httpd -f -p 80 -h /www` (busybox 에 들어 있는 작은 웹 서버)
2. 이미지를 **`hello-site:1.0`** 으로 빌드하세요.
3. 그 이미지로 컨테이너 **`site`** 를 백그라운드로 띄우고, 내 서버 **8081** 포트를 컨테이너 **80** 에 연결하세요.
4. `curl http://localhost:8081/about.html` 이 소개 페이지를 보여줘야 해요.

## Dockerfile 기본 문법
```dockerfile
FROM 베이스이미지          # 무엇 위에 쌓을지
COPY 내파일 이미지안경로   # 빌드 폴더의 파일을 이미지 안으로
RUN 명령                  # 빌드할 때 실행 (설치 등)
CMD ["프로그램", "인자"]   # 컨테이너가 시작할 때 실행
```

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `nano Dockerfile` | 파일 작성 |
| `docker build -t 이름:태그 .` | 현재 폴더(`.`)를 재료로 빌드 |
| `docker images` | 빌드된 이미지 확인 |
| `docker run --rm hello-site:1.0 ls -R /www` | 이미지 안에 파일이 잘 들어갔는지 확인 |
