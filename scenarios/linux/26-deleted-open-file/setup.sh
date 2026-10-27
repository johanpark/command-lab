#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
name=$(rand_pick payment-logger billing-agent audit-writer)
secret_set name "$name"
mkdir -p /var/log/shop && chown "$LEARNER:$LEARNER" /var/log/shop
cat > "/usr/local/bin/$name" <<'SCRIPT'
#!/bin/bash
# 로그 파일을 열어 두고 계속 쓴다
exec 3>> /var/log/shop/app.log
head -c 80000000 /dev/zero | tr '\0' '.' >&3
while :; do echo "$(date '+%F %T') payment ok" >&3; sleep 2; done
SCRIPT
chmod 755 "/usr/local/bin/$name"
for n in web-server; do printf '#!/bin/bash\nwhile :; do sleep 30; done\n' > "/usr/local/bin/$n"; chmod 755 "/usr/local/bin/$n"; done
spawn_bg /usr/local/bin/web-server
spawn_bg "/usr/local/bin/$name"
for i in $(seq 1 50); do [ "$(stat -c %s /var/log/shop/app.log 2>/dev/null || echo 0)" -ge 80000000 ] && break; sleep 0.2; done
echo "$(date '+%F %T') rotated" > /var/log/shop/old.log; chown -R "$LEARNER:$LEARNER" /var/log/shop
rm /var/log/shop/app.log
