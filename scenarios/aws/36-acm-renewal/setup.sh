#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret; T=$(mktemp -d); cd "$T"
# 인증 기관(CA) 흉내
openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -subj "/CN=Lab Trust CA" -keyout ca.key -out ca.crt 2>/dev/null
cert() { # 이름 일수 도메인들...
  local n=$1 days=$2; shift 2
  local san; san=$(printf 'DNS:%s,' "$@"); san=${san%,}
  openssl req -newkey rsa:2048 -nodes -subj "/CN=$1" -keyout "$n.key" -out "$n.csr" 2>/dev/null
  printf 'subjectAltName=%s\n' "$san" > "$n.ext"
  openssl x509 -req -in "$n.csr" -CA ca.crt -CAkey ca.key -CAcreateserial -days "$days" -extfile "$n.ext" -out "$n.crt" 2>/dev/null
}
imp() { aws acm import-certificate --certificate "fileb://$1.crt" --private-key "fileb://$1.key" --certificate-chain fileb://ca.crt --query CertificateArn --output text; }
d1=$(rand_int 9 14)
cert shop "$d1" shop.example www.shop.example
cert event "$(rand_int 18 27)" old-event.shop.example
cert admin "$(rand_int 150 250)" admin.shop.example
cert partner "$(rand_int 45 60)" partner.shop.example
SHOP=$(imp shop); EVT=$(imp event); ADM=$(imp admin); PAR=$(imp partner)
secret_set shop "$SHOP"; secret_set event "$EVT"; secret_set admin "$ADM"; secret_set partner "$PAR"
# 로드 밸런서: shop 은 운영 리스너, partner 는 파트너 전용 리스너
V=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)
SN=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="$V" --query 'Subnets[0:2].SubnetId' --output text)
LB=$(aws elbv2 create-load-balancer --name shop-alb --subnets $SN --query 'LoadBalancers[0].LoadBalancerArn' --output text)
TG=$(aws elbv2 create-target-group --name web-tg --protocol HTTP --port 80 --vpc-id "$V" --query 'TargetGroups[0].TargetGroupArn' --output text)
aws elbv2 create-listener --load-balancer-arn "$LB" --protocol HTTPS --port 443 --certificates CertificateArn="$SHOP" \
  --default-actions Type=forward,TargetGroupArn="$TG" --query 'Listeners[0].ListenerArn' --output text > $S/listener
aws elbv2 create-listener --load-balancer-arn "$LB" --protocol HTTPS --port 8443 --certificates CertificateArn="$PAR" \
  --default-actions Type=forward,TargetGroupArn="$TG" >/dev/null
# 업체에서 받은 새 인증서 (1년) + 작년 것(헷갈리라고)
cert shop-2027 397 shop.example www.shop.example
mkdir -p "$H/certs"
cp shop-2027.crt "$H/certs/shop.example-2027.crt"; cp shop-2027.key "$H/certs/shop.example-2027.key"; cp ca.crt "$H/certs/chain.crt"
cp shop.crt "$H/certs/shop.example-2026.crt"; cp shop.key "$H/certs/shop.example-2026.key"
openssl x509 -in shop-2027.crt -noout -serial | cut -d= -f2 | tr 'A-F' 'a-f' | sed 's/^0*//' > $S/new-serial
openssl x509 -in admin.crt -noout -enddate > $S/admin-end
cat > "$H/certs/README.txt" <<'TXT'
[인증서 업체 메일]
shop.example / www.shop.example 인증서 갱신본 보내드립니다. (유효기간 1년)
- shop.example-2027.crt  : 새 인증서
- shop.example-2027.key  : 개인 키
- chain.crt              : 중간 인증서 체인
(shop.example-2026.* 은 지금 쓰고 계신 것)
TXT
give "$H/certs"
cd /; rm -rf "$T"
