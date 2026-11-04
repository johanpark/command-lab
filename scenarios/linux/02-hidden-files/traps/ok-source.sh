# 설명: .env 를 source 해서 변수로 읽어도 맞는 풀이다
# 통과해야
. ~/webapp/.env && echo "$DB_PORT" > ~/answer.txt
