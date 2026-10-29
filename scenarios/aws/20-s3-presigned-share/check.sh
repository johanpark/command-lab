#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
B=$(secret_get bucket); S=/opt/cmdlab/secret; K=reports/2026-10-settlement.xlsx
f="$H/share-url.txt"
u=$(grep -v '^\s*$' "$f" 2>/dev/null | head -1 | tr -d '\r' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
if [ -z "$u" ]; then fail "~/share-url.txt 에 URL 을 저장했다"; finish; fi
pass "~/share-url.txt 에 URL 을 저장했다"
path=$(python3 -c 'import sys,urllib.parse as p; print(p.unquote(p.urlsplit(sys.argv[1]).path))' "$u")
q() { python3 -c 'import sys,urllib.parse as p; print(dict(p.parse_qsl(p.urlsplit(sys.argv[1]).query)).get(sys.argv[2],""))' "$u" "$1"; }
if [ "$path" = "/$B/$K" ]; then pass "10월 정산 확정본 파일의 링크다"
elif [[ $path == *draft* ]]; then fail "10월 정산 확정본 파일의 링크다 (그건 초안(draft)이에요)"
else fail "10월 정산 확정본 파일의 링크다 (지금: $path)"; fi
if [ -z "$(q X-Amz-Signature)" ]; then fail "미리 서명된 URL 이다 (서명이 없는 그냥 주소예요)"
else pass "미리 서명된 URL 이다"; fi
e=$(q X-Amz-Expires)
[ "$e" = 86400 ] && pass "유효기간이 24시간이다" || fail "유효기간이 24시간이다 (지금: ${e:-?}초)"
code=$(curl -s -o "$S/dl" -w '%{http_code}' "$u")
if [ "$code" != 200 ]; then fail "링크로 확정본 파일이 열린다 (HTTP $code)"
elif [ "$(sha256sum < "$S/dl" | cut -d' ' -f1)" != "$(cat $S/sha)" ]; then fail "링크로 확정본 파일이 열린다 (열리긴 하는데 다른 파일이에요)"
else pass "링크로 확정본 파일이 열린다"; fi
pub=""
aws s3api get-bucket-policy --bucket "$B" >/dev/null 2>&1 && pub+="버킷 정책 "
aws s3api get-bucket-acl --bucket "$B" --query 'Grants[].Grantee.URI' --output text | grep -q AllUsers && pub+="버킷 ACL "
for k in $(aws s3api list-objects-v2 --bucket "$B" --query 'Contents[].Key' --output text); do
  aws s3api get-object-acl --bucket "$B" --key "$k" --query 'Grants[].Grantee.URI' --output text | grep -q AllUsers && pub+="$k "
done
[ "$(aws s3api get-public-access-block --bucket "$B" --query 'PublicAccessBlockConfiguration.[BlockPublicAcls,IgnorePublicAcls,BlockPublicPolicy,RestrictPublicBuckets]' --output text 2>/dev/null | tr '\t' ' ')" = "True True True True" ] || pub+="퍼블릭 액세스 차단 해제 "
[ -z "$pub" ] && pass "버킷과 파일은 여전히 비공개다" || fail "버킷과 파일은 여전히 비공개다 (공개됨: ${pub% })"
finish
