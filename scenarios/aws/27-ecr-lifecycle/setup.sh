#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
aws ecr create-repository --repository-name shop-api >/dev/null
aws ecr create-repository --repository-name shop-web >/dev/null
: > $S/images   # digest<TAB>나이(일)<TAB>태그들(쉼표)
push() { # 저장소 나이 태그들...
  local repo=$1 age=$2; shift 2
  local m d
  m=$(jq -cn --arg s "$repo-$age-$*-$RANDOM" '{schemaVersion: 2, mediaType: "application/vnd.docker.distribution.manifest.v2+json",
    config: {mediaType: "application/vnd.docker.container.image.v1+json", digest: ("sha256:" + ($s | @base64)), size: 1}, layers: []}')
  d=sha256:$(printf %s "$m" | sha256sum | cut -c1-64)
  if [ $# = 0 ]; then aws ecr put-image --repository-name "$repo" --image-manifest "$m" --image-digest "$d" >/dev/null
  else for t in "$@"; do aws ecr put-image --repository-name "$repo" --image-manifest "$m" --image-digest "$d" --image-tag "$t" >/dev/null; done; fi
  [ "$repo" = shop-api ] && printf '%s\t%s\t%s\n' "$d" "$age" "$(IFS=,; echo "$*")" >> $S/images
  return 0
}
# shop-api: release 15개 (오래된 것부터), 최신은 prod 태그도 있음
for i in $(seq 0 14); do
  age=$(( (14 - i) * 5 + 1 ))
  if [ $i = 14 ]; then push shop-api 1 release-1.$i prod; else push shop-api $age release-1.$i; fi
done
# 개발 브랜치 이미지
n=0; for a in 2 6 10 13 15 21 30 45; do n=$((n + 1)); push shop-api $a "dev-$(printf %04x%02d $RANDOM $n)"; done   # 끝 두 자리로 겹치지 않게
# 태그 없는 찌꺼기 (같은 태그로 다시 push 하면 이전 이미지는 태그를 잃는다)
for a in 0 3 8 17 26 40; do push shop-api $a; done
push shop-web 3 release-2.0
aws ecr list-images --repository-name shop-web --query 'imageIds[].imageDigest' --output text > $S/web
mkdir -p "$H"
cat > "$H/ecr-policy.md" <<'MD'
# shop-api 이미지 보관 규칙 (플랫폼팀 합의)

1. **태그 없는 이미지**: 푸시하고 **1일** 지나면 삭제
2. **dev-** 로 시작하는 개발 이미지: 푸시하고 **14일** 지나면 삭제
3. **release-** 이미지: **최근 10개만** 남기고 나머지 삭제 (롤백용)
4. 그 밖의 태그(prod 등)는 규칙으로 지우지 않음

그리고 지금 쌓여 있는 **태그 없는 이미지는 오늘 바로 전부** 지울 것. (태그 있는 것은 규칙에 맡기기)
shop-web 저장소는 이번 작업 대상 아님.
MD
give "$H/ecr-policy.md"
