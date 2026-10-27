# 컨테이너끼리 연결이 안 돼요

`app` 컨테이너가 `db` 컨테이너에 접속해야 하는데 계속 실패합니다.

```
$ docker logs --tail 2 app
12:00:01 ERROR cannot reach db:5000 (bad address 'db')
12:00:03 ERROR cannot reach db:5000 (bad address 'db')
```

두 컨테이너 모두 잘 실행 중이에요. 문제는 **네트워크**입니다.

## 목표
1. **`shop-net`** 이라는 네트워크를 만드세요.
2. `app` 과 `db` 를 **둘 다** `shop-net` 에 연결하세요. (컨테이너를 다시 만들 필요는 없어요)
3. `app` 의 로그에 `OK connected to db` 가 나오면 성공이에요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker network ls` | 네트워크 목록 |
| `docker network create 이름` | 네트워크 만들기 |
| `docker network connect 네트워크 컨테이너` | 실행 중인 컨테이너를 네트워크에 연결 |
| `docker network inspect 이름` | 연결된 컨테이너 확인 |
| `docker exec app ping -c 1 db` | 컨테이너 **안에서** 명령 실행 |
| `docker logs -f app` | 로그 실시간 보기 (`Ctrl+C` 로 나오기) |
