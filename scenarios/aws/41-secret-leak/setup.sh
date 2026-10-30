#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
OLD="Shop$(rand_int 1000 9999)!pass"; secret_set old "$OLD"
aws rds create-db-instance --db-instance-identifier shop-db --engine postgres --db-instance-class db.t3.medium \
  --master-username shopadmin --master-user-password "$OLD" --allocated-storage 50 --no-publicly-accessible >/dev/null
EP=$(aws rds describe-db-instances --db-instance-identifier shop-db --query 'DBInstances[0].Endpoint.Address' --output text)
aws rds create-db-instance --db-instance-identifier report-db --engine postgres --db-instance-class db.t3.small \
  --master-username reporter --master-user-password "Rep$(rand_int 1000 9999)!pw" --allocated-storage 20 >/dev/null
jq -cn --arg p "$OLD" --arg h "$EP" '{engine: "postgres", host: $h, port: 5432, username: "shopadmin", password: $p, dbname: "shop"}' > $S/orig.json
aws secretsmanager create-secret --name prod/shop/db --description "운영 DB 접속 정보" --secret-string "$(cat $S/orig.json)" >/dev/null
aws secretsmanager create-secret --name prod/report/db --secret-string '{"username":"reporter","password":"(그대로)"}' >/dev/null
aws secretsmanager describe-secret --secret-id prod/shop/db --query 'VersionIdsToStages' --output json \
  | jq -r 'to_entries[] | select(.value | index("AWSCURRENT")) | .key' > $S/old-version
aws secretsmanager get-secret-value --secret-id prod/report/db --query SecretString --output text > $S/report
mkdir -p "$H"
cat > "$H/incident.md" <<'MD'
# 🚨 보안 사고: 운영 DB 비밀번호 노출

오늘 14:02 사내 메신저 #dev-help 채널에 **prod/shop/db 비밀을 조회한 터미널 화면 캡처**가 올라옴 (14:20 삭제).
캡처에 password 값이 그대로 보였음 → **비밀번호를 지금 바로 교체**

보안팀 요구 사항
1. 새 비밀번호는 사람이 정하지 말고 **get-random-password** 로 **32자**, 특수문자 없이 (접속 URL 이 깨지지 않게)
2. RDS **shop-db** 의 마스터 비밀번호를 새 값으로 (바로 적용)
3. Secrets Manager **prod/shop/db** 의 password 만 새 값으로 — host, port, username 등 **다른 값은 그대로**
4. 옛 값은 AWSPREVIOUS 로만 남아 있어야 함 (사고 기록용)
5. report-db / prod/report/db 는 이번 사고와 무관
MD
give "$H/incident.md"
