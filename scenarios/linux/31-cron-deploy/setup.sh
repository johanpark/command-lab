#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
D="$H/deploy"; mkdir -p "$D/config" "$D/dist" "$H/.local/bin" "$H/site"
echo "SITE_DIR=$H/site" > "$D/config/deploy.env"
echo "<h1>nightly build</h1>" > "$D/dist/index.html"
printf '#!/usr/bin/env bash\necho "[notify] $*"\n' > "$H/.local/bin/notify"; chmod 755 "$H/.local/bin/notify"
cat > "$D/nightly.sh" <<'SH'
#!/usr/bin/env bash
# 매일 밤 cron 으로 실행되는 배포 스크립트
set -e
source ./config/deploy.env
cp ./dist/* "$SITE_DIR"/
date +%F > "$SITE_DIR/build.txt"
notify "야간 배포 완료"
echo "✅ 야간 배포 완료"
SH
chmod 755 "$D/nightly.sh"
cat > "$D/cron.log" <<'LOG'
[2026-10-25 03:00:01] /home/learner/deploy/nightly.sh: line 4: ./config/deploy.env: No such file or directory
[2026-10-26 03:00:01] /home/learner/deploy/nightly.sh: line 4: ./config/deploy.env: No such file or directory
[2026-10-27 03:00:01] /home/learner/deploy/nightly.sh: line 4: ./config/deploy.env: No such file or directory
LOG
give "$D" "$H/.local" "$H/site"
