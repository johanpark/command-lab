# 설명: 사무실 IP 까지 막고, 기본 동작을 차단으로, 속도 제한 없이, admin-alb 에도 건다
# 실패해야: 회사 사무실 IP
# 실패해야: 기본 동작이 허용
# 실패해야: 속도 제한 규칙
# 실패해야: admin-alb 는 그대로
ADDR=$(grep -oE '^\| [0-9./]+' ~/attack-report.md | tr -d '| ')
IPARN=$(aws wafv2 create-ip-set --name blocked-ips --scope REGIONAL --ip-address-version IPV4 --addresses $ADDR --query Summary.ARN --output text)
jq -n --arg a "$IPARN" '[{Name:"b",Priority:0,Statement:{IPSetReferenceStatement:{ARN:$a}},Action:{Block:{}},VisibilityConfig:{SampledRequestsEnabled:true,CloudWatchMetricsEnabled:true,MetricName:"b"}}]' > r.json
ACL=$(aws wafv2 create-web-acl --name shop-waf --scope REGIONAL --default-action Block={} --rules file://r.json --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=w --query Summary.ARN --output text)
for n in shop-alb admin-alb; do aws wafv2 associate-web-acl --web-acl-arn $ACL --resource-arn $(aws elbv2 describe-load-balancers --names $n --query 'LoadBalancers[0].LoadBalancerArn' --output text); done
