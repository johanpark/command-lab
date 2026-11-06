# 설명: 마지막 20줄을 head 로 뽑으면 첫 20줄이 된다
# 실패해야: 마지막 20줄
grep -c ERROR ~/logs/app.log > ~/answer.txt
head -n 20 ~/logs/app.log > ~/recent.log
grep ERROR ~/logs/app.log > ~/errors.log
