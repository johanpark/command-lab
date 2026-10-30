#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
T=$(mktemp -d); printf 'def handler(event, context):\n    return {"ok": True}\n' > "$T/app.py"
python3 -c "import zipfile,sys; z=zipfile.ZipFile(sys.argv[1]+'/f.zip','w'); z.write(sys.argv[1]+'/app.py','app.py')" "$T"
aws iam create-role --role-name order-api-role --assume-role-policy-document \
  '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}' >/dev/null
R=arn:aws:iam::123456789012:role/order-api-role
envs() { jq -cn --arg db "$1" --arg lv "$2" --arg pg "$3" '{Variables: {DB_HOST: $db, LOG_LEVEL: $lv, PG_API_URL: $pg, FEATURE_COUPON: "on"}}'; }
PG=https://api.pg.example/v2
aws lambda create-function --function-name order-api --runtime python3.12 --role "$R" --handler app.handler \
  --zip-file "fileb://$T/f.zip" --timeout 10 --environment "$(envs db-1.internal info $PG)" >/dev/null
aws lambda publish-version --function-name order-api --description "v1 첫 배포" >/dev/null
aws lambda update-function-configuration --function-name order-api --timeout 15 --environment "$(envs db-2.internal info $PG)" >/dev/null
aws lambda publish-version --function-name order-api --description "v2 DB 이전 (db-2)" >/dev/null
aws lambda update-function-configuration --function-name order-api --timeout 15 --environment "$(envs db-2.intrenal debug $PG)" >/dev/null
aws lambda publish-version --function-name order-api --description "v3 로그 레벨 조정" >/dev/null
aws lambda create-alias --function-name order-api --name live --function-version 3 >/dev/null
aws lambda create-alias --function-name order-api --name staging --function-version 3 >/dev/null
envs db-2.internal debug $PG | jq -cS .Variables > $S/want-env
C=$(rand_pick 50 80 100); secret_set conc "$C"
rm -rf "$T"
mkdir -p "$H"
cat > "$H/incident.md" <<MD
# 🚨 주문 API 장애 (10분 전 배포 직후)

CloudWatch Logs:
\`\`\`
[ERROR] OperationalError: could not translate host name "db-2.intrenal" to address
[ERROR] OperationalError: could not translate host name "db-2.intrenal" to address
... (1분에 수천 건)
\`\`\`

- 방금 배포: **버전 3** (로그 레벨을 debug 로 바꾸면서 DB_HOST 를 잘못 입력함: intrenal → internal)
- 운영 트래픽은 별칭 **live** 로 들어옴, QA 는 별칭 **staging** 으로 테스트

할 일
1. 급한 불: live 를 **장애 직전 정상 버전**으로 되돌리기
2. \$LATEST 의 DB_HOST 를 **db-2.internal** 로 고치고 (다른 환경 변수는 그대로!) 새 버전 발행
3. 새 버전은 **staging 에만** 연결 (QA 확인 후 live 반영 예정)
4. 에러 재시도로 DB 연결이 폭주했으니, 함수의 **예약 동시 실행을 ${C}** 으로 제한
MD
give "$H/incident.md"
