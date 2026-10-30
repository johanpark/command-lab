보고서의 출발지 목록에서 **사무실 IP 만 빼고** IP 집합을 만들어요:
`cat ~/office.txt` 로 사무실 IP 를 확인한 뒤
`aws wafv2 create-ip-set --name blocked-ips --scope REGIONAL --ip-address-version IPV4 --addresses 45.x.x.17/32 45.x.x.18/32 185.x.x.0/24 91.x.x.x/32 --query Summary.ARN --output text`
(단일 IP 도 `/32` 를 붙여야 해요)
---
`rules.json` 은 규칙 **두 개짜리 배열** `[ {...}, {...} ]` 이에요. Priority 는 0, 1 처럼 서로 달라야 해요.
속도 규칙: `"Statement": {"RateBasedStatement": {"Limit": <보고서의 횟수>, "AggregateKeyType": "IP"}}`, `"Action": {"Block": {}}`
`jq . rules.json` 으로 문법부터 확인하세요.
---
```
aws wafv2 create-web-acl --name shop-waf --scope REGIONAL --default-action Allow={} --rules file://rules.json \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=shop-waf --query Summary.ARN --output text
```
---
`aws wafv2 associate-web-acl --web-acl-arn <ACL ARN> --resource-arn $(aws elbv2 describe-load-balancers --names shop-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text)`
