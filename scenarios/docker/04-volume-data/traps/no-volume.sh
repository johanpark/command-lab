# 설명: 볼륨 없이 새 버전을 띄우고 데이터만 복사하면 다음 업그레이드 때 또 사라진다
# 실패해야: memo-data 볼륨이 연결
docker cp memo:/data/memos.txt ~/memos-backup.txt
docker rm -f memo
docker run -d --name memo memo:1.1
docker cp ~/memos-backup.txt memo:/data/memos.txt
