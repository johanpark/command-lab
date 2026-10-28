#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
D="$H/.ssh"; mkdir -p "$D"; give "$D"; chmod 700 "$D"
as_learner ssh-keygen -q -t ed25519 -N '' -f "$D/web_key" -C web
as_learner ssh-keygen -q -t ed25519 -N '' -f "$D/db_key" -C db
web_ip="10.20.$(rand_int 1 9).$(rand_int 10 250)"; db_ip="10.20.$(rand_int 10 19).$(rand_int 10 250)"
web_port=$(rand_int 2200 2299); web_user=$(rand_pick deploy release www); db_user=$(rand_pick dbadmin dba postgres)
printf '%s\n' "$web_ip" "$web_user" "$web_port" "$db_ip" "$db_user" > /opt/cmdlab/secret/servers
cat > "$H/servers.txt" <<TXT
별칭   주소           사용자     포트   키 파일
web    $web_ip    $web_user    $web_port   ~/.ssh/web_key
db     $db_ip     $db_user    22     ~/.ssh/db_key
TXT
cat > "$D/config" <<'CFG'
# 회사 공통 설정 (모든 서버)
Host *
    User admin
    ServerAliveInterval 60

Host bastion
    HostName 10.0.0.5
CFG
give "$H/servers.txt" "$D/config"; chmod 666 "$D/config"
