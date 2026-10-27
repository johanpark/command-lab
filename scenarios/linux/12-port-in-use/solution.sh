name=$(sudo ss -Hltnp 'sport = :8080' | grep -o '(("[^"]*"' | cut -d'"' -f2)
echo "$name" > ~/answer.txt
sudo pkill -x "$name"
for i in $(seq 1 20); do ss -ltn | grep -q ':8080 ' || break; sleep 0.2; done
~/myapp/start.sh
