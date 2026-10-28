# unhealthy 컨테이너 살리기 (헬스체크)

로드밸런서가 서비스 하나를 계속 "장애"로 빼 버린대요. 그런데 `docker ps` 를 보면 컨테이너는 다 **Up** 이에요. 잘 보면 하나만 상태 옆에 `(unhealthy)` 가 붙어 있어요.

이 이미지들에는 **헬스체크**가 들어 있어요. Docker 가 몇 초마다 `/health` 주소를 불러 보고, 실패가 이어지면 `unhealthy` 로 표시해요.

## 목표
1. **unhealthy 인 컨테이너 이름**을 `~/answer.txt` 에 저장하세요.
2. 헬스체크 기록과 로그로 **원인**을 찾아, 그 컨테이너가 **healthy** 가 되도록 고치세요.
3. 고친 컨테이너는 **같은 이름, 같은 이미지, 같은 포트**, 원래 있던 **다른 환경 변수**와 **재시작 정책**을 그대로 가져야 해요.
4. 다른 컨테이너는 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker ps` | STATUS 에 `(healthy)` / `(unhealthy)` 표시 |
| `docker ps --filter health=unhealthy` | unhealthy 만 |
| `docker inspect -f '{{json .State.Health}}' 이름` | 헬스체크 결과 기록 |
| `docker logs 이름` | 앱 로그 |
| `docker inspect -f '{{.Config.Env}}' 이름` | 환경 변수 |
| `docker inspect -f '{{.HostConfig.PortBindings}}' 이름` | 포트 연결 |
