# 설명: 데이터를 꺼내 두지 않고 컨테이너를 지우면 메모가 사라진다
# 실패해야: 기존 메모가 그대로
docker rm -f memo
docker volume create memo-data
docker run -d --name memo -v memo-data:/data memo:1.1
