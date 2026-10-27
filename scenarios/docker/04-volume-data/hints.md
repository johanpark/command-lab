먼저 백업! `docker cp memo:/data/memos.txt ~/memos-backup.txt` 로 내 서버에 복사하고 `cat` 으로 확인하세요. 이게 없으면 다음 단계로 가면 안 돼요.
---
`docker rm -f memo` 로 옛 컨테이너를 지우고, `docker volume create memo-data` → `docker run -d --name memo -v memo-data:/data memo:1.1`
---
새 볼륨은 비어 있어요. 백업해 둔 파일을 넣으세요: `docker cp ~/memos-backup.txt memo:/data/memos.txt`
---
`docker exec memo cat /data/memos.txt` 로 확인. 진짜 지켜지는지 보려면 `docker rm -f memo` 후 같은 run 명령으로 다시 만들고 다시 cat 해 보세요!
