#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
B=$(secret_get backups); W=$(secret_get website)
# 버킷의 '키 md5' 목록 (작은 파일은 ETag 가 곧 md5)
objs() { aws s3api list-objects-v2 --bucket "$1" ${2:+--prefix "$2"} --query 'Contents[].[Key,ETag]' --output text 2>/dev/null | tr -d '"' | awk 'NF == 2 { print $1, $2 }' | sort; }
got=$(objs "$B" db/2026-10-29/)
if [ "$got" = "$(cat /opt/cmdlab/secret/backup)" ]; then pass "백업이 s3://$B/db/2026-10-29/ 에 그대로 올라갔다"
elif aws s3api list-objects-v2 --bucket "$B" --query 'Contents[].Key' --output text 2>/dev/null | grep -q 'db-2026-10-29/'; then fail "백업이 s3://$B/db/2026-10-29/ 에 그대로 올라갔다 (db-2026-10-29/ 폴더가 한 겹 더 들어갔어요)"
else fail "백업이 s3://$B/db/2026-10-29/ 에 그대로 올라갔다 (지금 $(echo "$got" | sed '/^$/d' | wc -l)개, 기대 $(wc -l < /opt/cmdlab/secret/backup)개)"; fi
expect "어제 백업(db/2026-10-28/)은 그대로다" bash -c "aws s3api head-object --bucket '$B' --key db/2026-10-28/dump.sql.gz >/dev/null 2>&1"
got=$(objs "$W"); want=$(cat /opt/cmdlab/secret/site)
stale=$(comm -23 <(cut -d' ' -f1 <<< "$got") <(cut -d' ' -f1 <<< "$want") | grep -v '^drafts/' | tr '\n' ' ')
drafts=$(cut -d' ' -f1 <<< "$got" | grep '^drafts/' | tr '\n' ' ')
[ -z "$stale" ] && pass "로컬에서 지운 옛 파일이 버킷에 남아 있지 않다" || fail "로컬에서 지운 옛 파일이 버킷에 남아 있지 않다 (남음: $stale— sync --delete)"
[ -z "$drafts" ] && pass "초안(drafts/)은 올라가지 않았다" || fail "초안(drafts/)은 올라가지 않았다 (올라감: $drafts— --exclude 'drafts/*')"
[ "$(grep -v '^drafts/' <<< "$got")" = "$want" ] && pass "웹사이트 버킷이 로컬 ~/site 와 똑같다 (최신 내용)" \
  || fail "웹사이트 버킷이 로컬 ~/site 와 똑같다 (빠졌거나 옛 내용인 파일이 있어요)"
finish
