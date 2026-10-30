#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; B=$(secret_get bucket); I=$(secret_get inst); K=$(secret_get key)
R=report-server-role
trust=$(aws iam get-role --role-name $R --query Role.AssumeRolePolicyDocument --output json 2>/dev/null)
if [ -z "$trust" ]; then fail "report-server-role 을 EC2 가 맡을 수 있다 (역할이 없어요)"
elif jq -e '[.Statement | if type == "array" then .[] else . end | select(.Effect == "Allow")
     | select([.Principal.Service] | flatten | index("ec2.amazonaws.com"))
     | select([.Action] | flatten | index("sts:AssumeRole"))] | length > 0' >/dev/null <<< "$trust"; then
  pass "report-server-role 을 EC2 가 맡을 수 있다"
else fail "report-server-role 을 EC2 가 맡을 수 있다 (신뢰 정책에 ec2.amazonaws.com + sts:AssumeRole 이 없어요)"; fi
# 역할의 모든 정책 문장 모으기 (인라인 + 관리형 기본 버전)
docs=$( { for p in $(aws iam list-role-policies --role-name $R --query PolicyNames --output text 2>/dev/null); do
            aws iam get-role-policy --role-name $R --policy-name "$p" --query PolicyDocument --output json; done
          for a in $(aws iam list-attached-role-policies --role-name $R --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null); do
            v=$(aws iam get-policy --policy-arn "$a" --query Policy.DefaultVersionId --output text)
            aws iam get-policy-version --policy-arn "$a" --version-id "$v" --query PolicyVersion.Document --output json; done; } \
        | jq -c '.Statement | if type == "array" then .[] else . end | select(.Effect == "Allow")
                 | {a: ([.Action] | flatten), r: ([.Resource] | flatten)}' 2>/dev/null)
has() { # 작업 리소스 → 허용하는 문장이 있나 (IAM 와일드카드 * ? 비교)
  DOCS="$docs" python3 - "$1" "$2" <<'PY'
import fnmatch, json, os, sys
a, r = sys.argv[1], sys.argv[2]
st = [json.loads(l) for l in os.environ['DOCS'].splitlines() if l.strip()]
ok = any(any(fnmatch.fnmatchcase(a.lower(), x.lower()) for x in s['a']) and any(fnmatch.fnmatchcase(r, x) for x in s['r']) for s in st)
sys.exit(0 if ok else 1)
PY
}
miss=""
has s3:GetObject "arn:aws:s3:::any-bucket/file" || miss+="S3 읽기, "
has s3:ListBucket "arn:aws:s3:::any-bucket" || miss+="버킷 목록, "
has s3:PutObject "arn:aws:s3:::$B/2026/report.xlsx" || miss+="$B 업로드, "
wide=""
has s3:PutObject "arn:aws:s3:::other-bucket/x" && wide+="다른 버킷에도 업로드 가능, "
has iam:CreateUser "*" && wide+="관리자급 권한, "
has s3:DeleteBucket "arn:aws:s3:::$B" && wide+="버킷 삭제 가능, "
if [ -n "$miss" ]; then fail "역할에 report-bot 과 같은 권한이 있다 (빠짐: ${miss%, })"
elif [ -n "$wide" ]; then fail "역할에 report-bot 과 같은 권한만 있다 (너무 넓어요: ${wide%, })"
else pass "역할에 report-bot 과 같은 권한만 있다"; fi
pr=$(aws iam get-instance-profile --instance-profile-name report-server-profile --query 'InstanceProfile.Roles[].RoleName' --output text 2>/dev/null)
[ "$pr" = $R ] && pass "report-server-profile 에 역할이 들어 있다" || fail "report-server-profile 에 역할이 들어 있다 (지금: ${pr:-프로파일 없음})"
assoc=$(aws ec2 describe-iam-instance-profile-associations --filters Name=instance-id,Values="$I" \
  --query "IamInstanceProfileAssociations[?State=='associated' || State=='associating'].IamInstanceProfile.Arn" --output text 2>/dev/null)
[[ "$assoc" == *":instance-profile/report-server-profile" ]] && pass "report-server 인스턴스에 프로파일이 연결돼 있다" || fail "report-server 인스턴스에 프로파일이 연결돼 있다${assoc:+ (지금: $assoc)}"
E="$H/report-server/.env"
if grep -qE 'AWS_(ACCESS_KEY_ID|SECRET_ACCESS_KEY)|AKIA' "$E" 2>/dev/null; then fail ".env 에서 액세스 키를 지웠다"
elif [ "$(grep -vE '^AWS_(ACCESS_KEY_ID|SECRET_ACCESS_KEY)=' "$E" 2>/dev/null)" = "$(cat $S/env-rest)" ]; then pass ".env 에서 액세스 키 두 줄만 지웠다"
else fail ".env 에서 액세스 키 두 줄만 지웠다 (다른 설정까지 바뀌었어요)"; fi
st=$(aws iam list-access-keys --user-name report-bot --query "AccessKeyMetadata[?AccessKeyId=='$K'].Status" --output text 2>/dev/null)
case "$st" in
  Inactive) pass "report-bot 의 키를 비활성화했다 (삭제는 안 함)" ;;
  Active) fail "report-bot 의 키를 비활성화했다" ;;
  *) fail "report-bot 의 키를 비활성화했다 (키를 삭제했어요. 며칠 지켜본 뒤에 지워야 해요)" ;;
esac
finish
