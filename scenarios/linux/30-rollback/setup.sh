#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
A="$H/app"; R="$A/releases"
missing=$(rand_pick health config.json)
secret_set missing "$missing"
for v in 2.3.0 2.3.1 2.4.0; do
  mkdir -p "$R/$v/public"
  echo "$v" > "$R/$v/public/version.txt"
  echo "<h1>shop $v</h1>" > "$R/$v/public/index.html"
  echo ok > "$R/$v/public/health"
  echo '{"theme":"light"}' > "$R/$v/public/config.json"
done
echo '<h1>shop 2.4.0 - 새 디자인</h1>' > "$R/2.4.0/public/index.html"
rm "$R/2.4.0/public/$missing"
# health 가 빠졌으면 헬스 체크가 실패. config.json 이 빠졌으면 health 가 에러를 보고하게
if [ "$missing" = config.json ]; then echo "error: config.json not found" > "$R/2.4.0/public/health"; fi
ln -sfn releases/2.4.0 "$A/current"
cat > "$A/restart.sh" <<'SH'
#!/usr/bin/env bash
# 서버(busybox httpd)를 재시작한다. current 링크를 시작할 때 따라간다.
pkill -f 'httpd -p 127.0.0.1:8080' 2>/dev/null && sleep 0.5
busybox httpd -p 127.0.0.1:8080 -h "$HOME/app/current/public"
echo "재시작 완료: $(readlink "$HOME/app/current")"
SH
chmod 755 "$A/restart.sh"
give "$A"
as_learner "$A/restart.sh" >/dev/null
(cd "$R/2.4.0" && find . | sort) > /opt/cmdlab/secret/v240-files
