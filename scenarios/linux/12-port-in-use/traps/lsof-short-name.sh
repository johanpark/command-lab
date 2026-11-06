# 설명: lsof 기본 출력은 프로세스 이름을 9글자로 잘라서, 그대로 적으면 이름이 틀린다
# 실패해야: answer.txt 에 8080 을 점유하던 프로세스 이름을 적었다
pid=$(sudo lsof -t -i :8080 | head -n 1)
sudo lsof -i :8080 | awk 'NR == 2 { print $1 }' > ~/answer.txt
sudo kill "$pid"
for i in $(seq 1 20); do ss -ltn | grep -q ':8080 ' || break; sleep 0.2; done
~/myapp/start.sh
