#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
A="$H/app"; mkdir -p "$A"
host="db-$(rand_int 10 99).internal"; pw="pw$(rand_int 100000 999999)"
secret_set host "$host"; secret_set pw "$pw"
printf '# DB 설정 (커밋 금지)\nDB_HOST=%s\nDB_USER=shop\nDB_PASSWORD=%s\n' "$host" "$pw" > "$A/.env"
cat > "$A/run.sh" <<'SH'
#!/usr/bin/env bash
# 환경 변수로 설정을 받는 앱
for v in APP_ENV LOG_LEVEL DB_HOST DB_USER DB_PASSWORD; do
  if [ -z "${!v}" ]; then echo "❌ $v 가 설정되지 않았습니다"; exit 1; fi
done
[ "$APP_ENV" = production ] || { echo "❌ APP_ENV 는 production 이어야 합니다 (지금: $APP_ENV)"; exit 1; }
{
  echo "APP_ENV=$APP_ENV"
  echo "LOG_LEVEL=$LOG_LEVEL"
  echo "DB_HOST=$DB_HOST"
  echo "DB_USER=$DB_USER"
  echo "DB_PASSWORD_SHA=$(printf '%s' "$DB_PASSWORD" | sha256sum | cut -c1-16)"
} > "$HOME/app/started.txt"
echo "✅ 앱 시작 ($APP_ENV, DB: $DB_HOST)"
SH
chmod 755 "$A/run.sh"
give "$A"
md5sum "$A/run.sh" "$A/.env" > /opt/cmdlab/secret/md5
