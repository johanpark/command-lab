#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
L="$H/app"; B="$H/remote/app.git"; rel=$(cat /opt/cmdlab/secret/release)
lt=$(git -C "$L" rev-parse -q --verify 'refs/tags/v1.2.0^{commit}' 2>/dev/null)
if [ "$lt" = "$rel" ]; then pass "v1.2.0 태그가 1.2.0 커밋('버전 1.2.0')을 가리킨다"
elif [ -n "$lt" ]; then fail "v1.2.0 태그가 1.2.0 커밋('버전 1.2.0')을 가리킨다 (지금: $(git -C "$L" log -1 --format='%h %s' "$lt") — HEAD 에 달았나요?)"
else fail "v1.2.0 태그가 1.2.0 커밋('버전 1.2.0')을 가리킨다 (태그가 없어요)"; fi
type=$(git -C "$L" cat-file -t refs/tags/v1.2.0 2>/dev/null)
[ "$type" = tag ] && pass "설명 붙은(annotated) 태그다" || fail "설명 붙은(annotated) 태그다 (지금: ${type:-없음} — git tag -a)"
msg=$(git -C "$L" tag -l --format='%(contents:subject)' v1.2.0 2>/dev/null)
[ "$msg" = "1.2.0 릴리스" ] && pass "태그 메시지가 '1.2.0 릴리스' 다" || fail "태그 메시지가 '1.2.0 릴리스' 다 (지금: '$msg')"
rt=$(git -C "$B" rev-parse -q --verify 'refs/tags/v1.2.0^{commit}' 2>/dev/null)
[ -n "$rt" ] && [ "$rt" = "$rel" ] && pass "원격(origin)에 v1.2.0 태그가 올라갔다" \
  || fail "원격(origin)에 v1.2.0 태그가 올라갔다 ($( [ -n "$rt" ] && echo '원격 태그가 다른 커밋을 가리켜요' || echo 'git push 로는 태그가 안 올라가요 — git push origin v1.2.0'))"
expect "브랜치와 기존 v1.1.0 태그는 그대로다" bash -c "[ \"\$(git -C '$B' rev-parse main)\" = \"\$(git -C '$L' rev-parse main)\" ] && git -C '$B' rev-parse -q --verify refs/tags/v1.1.0 >/dev/null"
finish
