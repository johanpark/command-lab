# 엉뚱한 서버로 접속해요

API 서버를 새 장비로 옮겼고, 새 서버는 **이 서버 자신(127.0.0.1)의 8000 포트**에서 돌고 있어요. 그런데 이 서버에서만 API 주소로 접속이 안 됩니다.

```
$ curl -m 3 http://api.internal:8000/health
curl: (28) Connection timed out after 3001 milliseconds
```

## 목표
1. `api.internal` 이라는 이름이 지금 **어떤 IP 로 풀리고 있는지** 찾아서 그 IP 를 `~/answer.txt` 에 저장하세요.
2. `api.internal` 이 **`127.0.0.1`** 로 풀리도록 고치세요.
3. `curl http://api.internal:8000/health` 가 `ok` 를 돌려줘야 합니다.
4. `/etc/hosts` 의 다른 줄(localhost 등)은 지우면 안 돼요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `curl -v -m 3 주소` | 접속 과정을 자세히 (어느 IP 로 붙는지 보임) |
| `getent hosts 이름` | 이 서버가 그 이름을 **어떤 IP 로** 아는지 |
| `cat /etc/hosts` | DNS 보다 먼저 보는 "이름 → IP" 수동 목록 |
| `sudo nano /etc/hosts` | 수정 (관리자 권한 필요) |
