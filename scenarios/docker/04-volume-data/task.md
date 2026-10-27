# 업그레이드해도 데이터 지키기

메모 서비스 컨테이너 `memo` (이미지 `memo:1.0`) 를 새 버전 **`memo:1.1`** 로 바꿔야 합니다. 그런데 문제가 있어요.

> 메모는 컨테이너 안의 `/data/memos.txt` 에 저장되고 있는데, 이 컨테이너는 **볼륨 없이** 만들어졌어요. 컨테이너를 지우면 메모도 같이 사라집니다!

## 목표
1. 지금 메모(`/data/memos.txt`)를 **잃지 않게** 보관하세요.
2. **`memo-data`** 라는 볼륨을 만들고, `memo:1.1` 이미지로 새 `memo` 컨테이너를 띄우되 볼륨을 **`/data`** 에 연결하세요.
3. 새 컨테이너의 `/data/memos.txt` 에 **기존 메모가 그대로** 있어야 합니다.
4. (확인) 이제는 컨테이너를 지우고 다시 만들어도 메모가 남아요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker exec memo cat /data/memos.txt` | 컨테이너 안의 파일 보기 |
| `docker cp memo:/data/memos.txt ~/` | 컨테이너 → 내 서버로 파일 복사 (반대 방향도 가능) |
| `docker volume create 이름` / `docker volume ls` | 볼륨 만들기 / 목록 |
| `docker run -v 볼륨:/경로 ...` | 볼륨을 컨테이너 경로에 연결 |
| `docker inspect memo --format '{{json .Mounts}}'` | 연결된 볼륨 확인 |
