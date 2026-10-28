#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
id deploy >/dev/null 2>&1 || useradd -m -s /bin/bash deploy
rm -f /etc/sudoers.d/deploy
cat > /usr/local/bin/app-restart <<'SH'
#!/usr/bin/env bash
if [ "$(id -u)" -ne 0 ]; then echo "app-restart: root 권한이 필요합니다" >&2; exit 1; fi
date '+%F %T' > /var/run/app-restarted
echo "✅ 앱 재시작 완료 (by ${SUDO_USER:-root})"
SH
chmod 755 /usr/local/bin/app-restart
