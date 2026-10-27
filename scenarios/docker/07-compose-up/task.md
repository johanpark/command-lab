# docker compose 로 한 번에 띄우기

웹(`web`)과 API(`api`) 컨테이너를 `docker run` 으로 하나씩 띄우는 대신, **`compose.yaml` 파일 하나로** 관리하려고 합니다. 동료가 `~/shop` 에 파일을 만들어 뒀는데, 실행하면 문제가 생겨요.

## 목표
1. `~/shop` 에서 `docker compose up -d` 가 **성공**하도록 `compose.yaml` 을 고치세요.
2. 두 서비스가 모두 실행 중이고,
   - `curl http://localhost:8080` → 쇼핑몰 웹 페이지
   - `curl http://localhost:3000/health` → `ok`
3. 문제는 **두 군데**예요. 에러 메시지를 잘 읽어 보세요.

## 써볼 명령어 (`~/shop` 안에서)
| 명령어 | 하는 일 |
|---|---|
| `cat compose.yaml` | 설정 보기 (들여쓰기가 의미를 가져요) |
| `docker compose up -d` | 정의된 서비스 전부 백그라운드로 실행 |
| `docker compose ps` | 서비스 상태 |
| `docker compose logs 서비스` | 서비스 로그 |
| `docker compose down` | 전부 정지 + 삭제 |
| `docker images` | 실제로 있는 이미지 이름과 태그 |

> 💡 Compose 는 같은 파일의 서비스들을 **자동으로 같은 네트워크**에 넣어서, 서비스 이름(`api`)으로 서로 찾을 수 있게 해 줘요.
