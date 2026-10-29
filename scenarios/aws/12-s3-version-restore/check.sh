#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
B=$(secret_get bucket); S=/opt/cmdlab/secret
norm() { jq -cS . 2>/dev/null; }
cur=$(aws s3 cp "s3://$B/prod/app.json" - 2>/dev/null)
if [ "$(norm <<< "$cur")" = "$(norm < $S/good.json)" ]; then pass "prod/app.json 이 깨지기 직전의 정상 버전이다"
elif ! norm <<< "$cur" >/dev/null || [ -z "$(norm <<< "$cur")" ]; then fail "prod/app.json 이 깨지기 직전의 정상 버전이다 (아직 깨진 JSON 이에요)"
elif [ "$(jq -r .version <<< "$cur")" = "1.3.2" ]; then fail "prod/app.json 이 깨지기 직전의 정상 버전이다 (그건 더 옛날 1.3.2 버전이에요)"
else fail "prod/app.json 이 깨지기 직전의 정상 버전이다 (내용이 달라요)"; fi
ff=$(aws s3 cp "s3://$B/prod/feature-flags.json" - 2>/dev/null)
[ -n "$ff" ] && [ "$(norm <<< "$ff")" = "$(norm < $S/ff.json)" ] \
  && pass "prod/feature-flags.json 을 되살렸다" || fail "prod/feature-flags.json 을 되살렸다"
vers=$(aws s3api list-object-versions --bucket "$B" --prefix prod/ --query 'Versions[].VersionId' --output text 2>/dev/null)
miss=0; while read -r v; do [[ " $(echo $vers) " == *" $v "* ]] || miss=$((miss + 1)); done < <(cat $S/app-versions $S/ff-version)
[ "$miss" = 0 ] && pass "기존 버전 기록을 지우지 않았다 (깨진 버전 포함)" || fail "기존 버전 기록을 지우지 않았다 (${miss}개 버전이 영구 삭제됐어요)"
ok=1; for k in staging/app.json prod/nginx.conf; do
  [ "$(aws s3api head-object --bucket "$B" --key "$k" --query ETag --output text 2>/dev/null)" = "$(cat "$S/etag-${k//\//_}")" ] || ok=0
done
[ $ok = 1 ] && pass "다른 파일(staging/, nginx.conf)은 그대로다" || fail "다른 파일(staging/, nginx.conf)은 그대로다"
finish
