# 컨테이너가 폴더에 못 써요 (볼륨 권한)

파일 업로드 서비스 `uploader` 컨테이너가 서버의 `/srv/uploads` 폴더를 `-v` 로 연결해서 써요. 그런데 업로드가 하나도 저장되지 않는대요.

```
$ docker logs uploader
ERROR cannot write /data/uploads/heartbeat.txt (uid=1000)
```

보안 때문에 이 이미지는 **root 가 아닌 사용자**로 실행되도록 만들어져 있어요.

## 목표
1. `uploader` 가 `/srv/uploads` 에 **쓸 수 있게** 고치세요. (잘 되면 몇 초마다 `/srv/uploads/heartbeat.txt` 가 갱신돼요)
2. 단, 이렇게 고치면 **안 돼요**
   - 컨테이너를 **root 로 실행** (`--user root`, `-u 0`)
   - 폴더를 **아무나 쓸 수 있게** (`chmod 777`)
3. 기존에 올라온 파일은 그대로 있어야 하고, 컨테이너는 같은 폴더를 계속 써야 해요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker logs uploader` | 로그 |
| `docker inspect -f '{{.Config.User}}' uploader` | 컨테이너를 실행하는 사용자 |
| `docker inspect -f '{{json .Mounts}}' uploader` | 연결된 폴더 |
| `docker exec uploader id` | 컨테이너 안에서 나는 누구? |
| `ls -ln /srv/uploads` | 소유자를 이름 대신 **번호(uid)** 로 |
| `sudo chown -R 번호:번호 폴더` | 소유자 바꾸기 |
