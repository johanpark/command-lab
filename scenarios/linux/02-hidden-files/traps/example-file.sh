# 설명: .env.example 의 예시 값(5432)을 적으면 틀린다
# 실패해야: 실제 설정(.env)의 DB_PORT
grep DB_PORT ~/webapp/.env.example | cut -d= -f2 > ~/answer.txt
