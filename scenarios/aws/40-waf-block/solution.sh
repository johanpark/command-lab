R=$(grep -oE '5분에 [0-9]+' ~/attack-report.md | grep -oE '[0-9]+$')
OFF=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' ~/office.txt)
ADDR=$(grep -oE '^\| [0-9./]+' ~/attack-report.md | tr -d '| ' | grep -v "^$OFF/")
IPARN=$(aws wafv2 create-ip-set --name blocked-ips --scope REGIONAL --ip-address-version IPV4 --addresses $ADDR --query Summary.ARN --output text)
jq -n --arg a "$IPARN" --argjson r "$R" '[
  {Name: "block-attackers", Priority: 0, Statement: {IPSetReferenceStatement: {ARN: $a}}, Action: {Block: {}},
   VisibilityConfig: {SampledRequestsEnabled: true, CloudWatchMetricsEnabled: true, MetricName: "block-attackers"}},
  {Name: "rate-limit", Priority: 1, Statement: {RateBasedStatement: {Limit: $r, AggregateKeyType: "IP"}}, Action: {Block: {}},
   VisibilityConfig: {SampledRequestsEnabled: true, CloudWatchMetricsEnabled: true, MetricName: "rate-limit"}}]' > ~/rules.json
ACL=$(aws wafv2 create-web-acl --name shop-waf --scope REGIONAL --default-action Allow={} --rules file://$HOME/rules.json \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=shop-waf --query Summary.ARN --output text)
ALB=$(aws elbv2 describe-load-balancers --names shop-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text)
aws wafv2 associate-web-acl --web-acl-arn "$ACL" --resource-arn "$ALB"
