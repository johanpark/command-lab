#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret
while read -r u; do
  if ! aws iam get-user --user-name "$u" >/dev/null 2>&1; then fail "$u: 계정이 남아 있다 (삭제했어요! 30일 동안은 지우면 안 돼요)"; continue; fi
  aws iam get-login-profile --user-name "$u" >/dev/null 2>&1 && fail "$u: 콘솔 비밀번호가 없다" || pass "$u: 콘솔 비밀번호가 없다"
  st=$(aws iam list-access-keys --user-name "$u" --query 'AccessKeyMetadata[].Status' --output text | wc -w)
  act=$(aws iam list-access-keys --user-name "$u" --query "AccessKeyMetadata[?Status=='Active'].AccessKeyId" --output text | wc -w)
  if [ "$st" != "$(cat "$S/keys-$u")" ]; then fail "$u: 액세스 키가 모두 비활성이다 (키를 삭제했어요. 비활성만 해야 해요)"
  elif [ "$act" != 0 ]; then fail "$u: 액세스 키가 모두 비활성이다 (아직 Active ${act}개)"
  else pass "$u: 액세스 키가 모두 비활성이다"; fi
  g=$(aws iam list-groups-for-user --user-name "$u" --query 'Groups[].GroupName' --output text)
  [ -z "$g" ] && pass "$u: 어느 그룹에도 없다" || fail "$u: 어느 그룹에도 없다 (아직: $g)"
  p=$(aws iam list-attached-user-policies --user-name "$u" --query 'AttachedPolicies[].PolicyName' --output text; aws iam list-user-policies --user-name "$u" --query 'PolicyNames' --output text)
  p=$(echo $p)
  [ -z "$p" ] && pass "$u: 직접 붙은 정책이 없다" || fail "$u: 직접 붙은 정책이 없다 (아직: $p)"
  t=$(aws iam list-user-tags --user-name "$u" --query "Tags[?Key=='Status'].Value" --output text)
  [ "$t" = offboarded ] && pass "$u: Status=offboarded 태그가 있다" || fail "$u: Status=offboarded 태그가 있다"
done < $S/gone
ok=1; bad=""
while read -r line; do
  u=$(jq -r .u <<< "$line")
  cur=$(jq -cn --arg u "$u" \
    --argjson keys "$(aws iam list-access-keys --user-name "$u" --query 'AccessKeyMetadata[].[AccessKeyId,Status]' --output json 2>/dev/null || echo null)" \
    --argjson groups "$(aws iam list-groups-for-user --user-name "$u" --query 'Groups[].GroupName' --output json 2>/dev/null || echo null)" \
    --argjson att "$(aws iam list-attached-user-policies --user-name "$u" --query 'AttachedPolicies[].PolicyArn' --output json 2>/dev/null || echo null)" \
    --argjson inl "$(aws iam list-user-policies --user-name "$u" --query 'PolicyNames' --output json 2>/dev/null || echo null)" \
    --arg login "$(aws iam get-login-profile --user-name "$u" >/dev/null 2>&1 && echo yes || echo no)" \
    '{u: $u, keys: ($keys | sort?), groups: ($groups | sort?), att: ($att | sort?), inl: ($inl | sort?), login: $login}')
  [ "$cur" = "$line" ] || { ok=0; bad+="$u "; }
done < $S/stay
[ $ok = 1 ] && pass "다른 직원·서비스 계정은 그대로다" || fail "다른 직원·서비스 계정은 그대로다 (바뀜: ${bad% })"
finish
