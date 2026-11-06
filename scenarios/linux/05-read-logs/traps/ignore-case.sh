# 설명: grep -i 로 찾으면 'previous error' 같은 INFO 줄까지 센다
# 실패해야: ERROR 줄 개수
# 실패해야: ERROR 줄만 모두
grep -ci error ~/logs/app.log > ~/answer.txt
tail -n 20 ~/logs/app.log > ~/recent.log
grep -i error ~/logs/app.log > ~/errors.log
