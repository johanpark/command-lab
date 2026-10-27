# 해설

```bash
docker exec app ping -c 1 db           # ping: bad address 'db'
docker network ls                      # bridge, host, none
docker network create shop-net
docker network connect shop-net db
docker network connect shop-net app
docker exec app ping -c 1 db           # 이제 응답
docker logs --tail 3 app               # OK connected to db
```

## 왜 기본 bridge 에서는 안 될까?
Docker 가 처음부터 갖고 있는 `bridge` 네트워크는 오래된 방식이라 **컨테이너 이름 → IP 변환(DNS)을 해 주지 않아요.** 직접 만든 네트워크에는 Docker 가 내장 DNS 를 붙여 주어서, 같은 네트워크의 컨테이너를 **이름으로** 찾을 수 있습니다.

## 처음부터 이렇게 띄우면 돼요
```bash
docker network create shop-net
docker run -d --name db  --network shop-net shop-db:1.0
docker run -d --name app --network shop-net shop-app:1.0
```
> Docker Compose 를 쓰면 서비스들을 자동으로 같은 네트워크에 넣어 주기 때문에 이 문제를 겪지 않아요.

## 함께 알아두기
- 컨테이너 안의 `localhost` 는 **그 컨테이너 자신**이에요. app 에서 `localhost:5000` 으로는 db 에 갈 수 없어요.
- `-p` 로 포트를 열지 않아도 같은 네트워크의 컨테이너끼리는 통신할 수 있어요. `-p` 는 **바깥(내 서버)** 에서 들어올 때만 필요합니다.
