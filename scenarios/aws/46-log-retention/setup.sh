#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
T=$(mktemp -d); printf 'def handler(event, context):\n    return {"ok": True}\n' > "$T/app.py"
python3 -c "import zipfile,sys; z=zipfile.ZipFile(sys.argv[1]+'/f.zip','w'); z.write(sys.argv[1]+'/app.py','app.py')" "$T"
aws iam create-role --role-name lambda-basic --assume-role-policy-document \
  '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}' >/dev/null
LIVE="order-api cart-api payment-webhook $(rand_pick image-resize thumbnail-maker) $(rand_pick coupon-batch point-expire)"
GONE="order-api-old $(rand_pick test-hello hello-world) $(rand_pick promo-2025-blackfriday event-chuseok-2025)"
for f in $LIVE; do
  aws lambda create-function --function-name "$f" --runtime python3.12 --role arn:aws:iam::123456789012:role/lambda-basic \
    --handler app.handler --zip-file "fileb://$T/f.zip" >/dev/null
done
rm -rf "$T"
lg() { aws logs create-log-group --log-group-name "$1"; [ -z "${2:-}" ] || aws logs put-retention-policy --log-group-name "$1" --retention-in-days "$2"; }
for f in $LIVE $GONE; do lg "/aws/lambda/$f"; done
for a in web api worker; do lg "/shop/app/$a"; done
lg /shop/audit/login; lg /shop/audit/payment 731
lg /shop/batch/nightly; lg /vpc/flow-logs 90
echo "$LIVE" | tr ' ' '\n' > $S/live; echo "$GONE" | tr ' ' '\n' > $S/gone
mkdir -p "$H"
cat > "$H/log-retention.md" <<'MD'
# CloudWatch Logs 보존 기간 규칙

지금 로그 그룹이 전부 **"만료 안 함(Never expire)"** 이라, 몇 년 치가 쌓여서 저장 요금이 매달 늘고 있어요.

| 로그 그룹 | 보존 기간 |
|---|---|
| `/aws/lambda/*` | **14일** |
| `/shop/app/*` | **30일** |
| `/shop/audit/*` | **400일 이상** (법무팀: 13개월 이상). 이미 더 길게 잡힌 건 **줄이지 말 것** |

- `/aws/lambda/<함수 이름>` 중에 **그 함수가 이제 없는 것**은 로그 그룹째 삭제
- 위 표에 없는 로그 그룹은 담당 팀이 따로 관리하니 **건드리지 말 것**
- 보존 기간은 아무 숫자나 안 돼요: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, ... 중에서
MD
give "$H/log-retention.md"
