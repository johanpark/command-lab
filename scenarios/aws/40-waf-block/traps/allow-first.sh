# 설명: 같은 IP 집합을 Allow 하는 규칙을 우선순위 0 에 두면 차단 규칙까지 가지 않는다
# 실패해야: 먼저 평가되는 허용 규칙
R=$(grep -oE '5분에 [0-9]+' ~/attack-report.md | grep -oE '[0-9]+$')
OFF=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' ~/office.txt)
ADDR=$(grep -oE '^\| [0-9./]+' ~/attack-report.md | tr -d '| ' | grep -v "^$OFF/")
IPARN=$(aws wafv2 create-ip-set --name blocked-ips --scope REGIONAL --ip-address-version IPV4 --addresses $ADDR --query Summary.ARN --output text)
jq -n --arg a "$IPARN" --argjson r "$R" '[
  {Name: "allow-ip", Priority: 0, Statement: {IPSetReferenceStatement: {ARN: $a}}, Action: {Allow: {}}, VisibilityConfig: {SampledRequestsEnabled: true, CloudWatchMetricsEnabled: true, MetricName: "allow-ip"}},
  {Name: "block-attackers", Priority: 5, Statement: {IPSetReferenceStatement: {ARN: $a}}, Action: {Block: {}},
   VisibilityConfig: {SampledRequestsEnabled: true, CloudWatchMetricsEnabled: true, MetricName: "block-attackers"}},
  {Name: "rate-limit", Priority: 6, Statement: {RateBasedStatement: {Limit: $r, AggregateKeyType: "IP"}}, Action: {Block: {}},
   VisibilityConfig: {SampledRequestsEnabled: true, CloudWatchMetricsEnabled: true, MetricName: "rate-limit"}}]' > ~/rules.json
ACL=$(aws wafv2 create-web-acl --name shop-waf --scope REGIONAL --default-action Allow={} --rules file://$HOME/rules.json \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=shop-waf --query Summary.ARN --output text)
ALB=$(aws elbv2 describe-load-balancers --names shop-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text)
aws wafv2 associate-web-acl --web-acl-arn "$ACL" --resource-arn "$ALB"
