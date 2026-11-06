#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
# 이름은 모두 10글자 이상: lsof·top 은 이름을 잘라 보여 준다(lsof 9글자) → 잘린 이름을 적는 실수를 배우게
name=$(rand_pick legacy-api old-gateway api-server-v1 proxy-server)
secret_set name "$name"
# nc(netcat) 를 이름만 바꿔 복사해서 '그럴듯한' 서버 프로세스로 쓴다
for b in "$name" metrics myapp; do cp /usr/bin/nc.openbsd "/usr/local/bin/$b"; done

# 범인: root 로 떠 있어서 sudo 가 필요하다
setsid nohup "/usr/local/bin/$name" -lk 0.0.0.0 8080 >/dev/null 2>&1 < /dev/null &
setsid nohup /usr/local/bin/metrics -lk 0.0.0.0 9100 >/dev/null 2>&1 < /dev/null &

mkdir -p "$H/myapp"
cat > "$H/myapp/start.sh" <<'SCRIPT'
#!/usr/bin/env bash
# myapp 을 8080 포트에서 백그라운드로 실행한다
if ss -ltn | grep -q ':8080 '; then
  echo "에러: 8080 포트가 이미 사용 중입니다." >&2
  exit 1
fi
setsid nohup /usr/local/bin/myapp -lk 0.0.0.0 8080 > "$HOME/myapp/app.log" 2>&1 < /dev/null &
sleep 0.5
echo "✅ myapp 이 8080 포트에서 시작됐습니다. (PID $!)"
SCRIPT
chmod 755 "$H/myapp/start.sh"
give "$H/myapp"
for i in $(seq 1 20); do ss -ltn | grep -q ':8080 ' && ss -ltn | grep -q ':9100 ' && break; sleep 0.2; done
