`cd ~/shop && docker compose up -d` 를 실행하고 에러를 읽어 보세요. 이미지를 받아오려다(pull) 실패하죠? `docker images` 와 compose.yaml 의 이미지 이름·태그를 한 글자씩 비교해 보세요.
---
`shop-web:1.O` 의 `O` 는 숫자 0 이 아니라 **알파벳 O** 예요. `nano compose.yaml` 로 `1.0` 으로 고치고 다시 `docker compose up -d`
---
이제 둘 다 Up 인데 `curl http://localhost:8080` 이 안 된다면, 포트 연결 방향을 보세요. `"바깥:안"` 순서예요. 웹 서버는 컨테이너 **안에서 80** 을 쓰고 있어요 (`docker compose logs web`).
---
`ports: - "8080:80"` 으로 고친 뒤 `docker compose up -d` 를 다시 하면, 바뀐 서비스만 새로 만들어 줘요.
