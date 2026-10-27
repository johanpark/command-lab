# 해설

```bash
docker exec memo cat /data/memos.txt
docker cp memo:/data/memos.txt ~/memos-backup.txt      # 1. 백업부터!
docker rm -f memo
docker volume create memo-data
docker run -d --name memo -v memo-data:/data memo:1.1
docker cp ~/memos-backup.txt memo:/data/memos.txt
docker exec memo cat /data/memos.txt                   # 그대로

# 확인: 지우고 다시 만들어도 남아 있음
docker rm -f memo && docker run -d --name memo -v memo-data:/data memo:1.1
docker exec memo cat /data/memos.txt
```

## 컨테이너 데이터의 규칙
- 컨테이너 안에 쓴 파일은 **컨테이너와 운명을 같이** 합니다. `docker rm` 하면 끝.
- 남겨야 하는 데이터(DB, 업로드 파일, 설정)는 반드시 **볼륨**이나 **바인드 마운트**에.

| 방식 | 예 | 특징 |
|---|---|---|
| 볼륨 | `-v memo-data:/data` | Docker 가 관리. 운영 데이터에 권장 |
| 바인드 마운트 | `-v ~/memos:/data` | 내 서버의 폴더를 그대로 연결. 개발할 때 편함 |
| (없음) | | 컨테이너 삭제 시 사라짐 |

## 볼륨 관리
```bash
docker volume ls
docker volume inspect memo-data      # 실제 저장 위치(Mountpoint)
docker volume rm memo-data           # 쓰는 컨테이너가 없어야 지워짐
```
