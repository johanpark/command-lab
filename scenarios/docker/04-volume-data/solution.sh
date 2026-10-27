docker cp memo:/data/memos.txt ~/memos-backup.txt
docker rm -f memo
docker volume create memo-data
docker run -d --name memo -v memo-data:/data memo:1.1
docker cp ~/memos-backup.txt memo:/data/memos.txt
