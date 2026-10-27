# 컨테이너 속 들여다보기

3년 전에 누군가 띄워 둔 컨테이너 **`legacy-app`** 이 아직 돌고 있어요. 문서는 없고, 만든 사람은 퇴사했습니다. 이 컨테이너를 새 서버로 옮기려면 정보가 필요해요.

## 목표
1. 컨테이너 안의 설정 파일 `/etc/legacy/app.conf` 에서 **`DB_HOST`** 값을 찾아 `~/answer.txt` 에 저장하세요.
2. 컨테이너에 설정된 **환경 변수 `TZ`** 의 값을 `~/tz.txt` 에 저장하세요.
3. 컨테이너 안의 에러 로그 `/var/log/legacy/error.log` 를 내 서버의 **`~/error.log`** 로 복사하세요.
4. 컨테이너는 **멈추거나 지우면 안 됩니다.**

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker exec legacy-app cat 파일` | 컨테이너 안에서 명령 한 번 실행 |
| `docker exec -it legacy-app sh` | 컨테이너 안으로 들어가기 (`exit` 로 나옴) |
| `docker inspect legacy-app` | 컨테이너의 모든 설정 (JSON) |
| `docker inspect -f '{{.Config.Env}}' legacy-app` | 원하는 부분만 |
| `docker cp 컨테이너:경로 내경로` | 파일 꺼내기 |
