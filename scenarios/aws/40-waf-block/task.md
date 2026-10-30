# 로그인 무차별 대입 공격 막기 (WAF IP 차단·속도 제한)

로그인 페이지에 비밀번호를 하나씩 대입해 보는 공격이 쏟아지고 있어요. 분석 결과는 `~/attack-report.md` 에 있어요.
**AWS WAF** 는 로드 밸런서 앞에서 요청을 검사해서, 규칙에 걸리는 요청을 서버에 닿기 전에 막아 줘요.

## 목표
1. 공격 출발지로 **IP 집합 `blocked-ips`** 를 만드세요. (`REGIONAL`, IPv4) **회사 사무실 IP 는 빼세요.**
2. **웹 ACL `shop-waf`** 를 만드세요. (`REGIONAL`, 기본 동작 **허용**)
   - 규칙 1: `blocked-ips` 에 있는 IP → **차단**
   - 규칙 2: IP 하나가 **5분에 정해진 횟수** 넘게 요청하면 → **차단** (속도 기반 규칙)
3. `shop-waf` 를 **`shop-alb`** 에 연결하세요. (`admin-alb` 는 대상 아님)

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws wafv2 create-ip-set --name 이름 --scope REGIONAL --ip-address-version IPV4 --addresses 1.2.3.4/32 ...` | IP 집합 |
| `aws wafv2 create-web-acl --name 이름 --scope REGIONAL --default-action Allow={} --rules file://rules.json --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=이름` | 웹 ACL |
| `aws elbv2 describe-load-balancers --names shop-alb --query 'LoadBalancers[0].LoadBalancerArn'` | 로드 밸런서 ARN |
| `aws wafv2 associate-web-acl --web-acl-arn ACL_ARN --resource-arn ALB_ARN` | 연결 |
| `aws wafv2 get-web-acl-for-resource --resource-arn ALB_ARN` | 확인 |

규칙 하나의 모양 (`rules.json` 은 이런 규칙들의 **배열**):
```json
{"Name": "이름", "Priority": 0,
 "Statement": {"IPSetReferenceStatement": {"ARN": "IP 집합 ARN"}},
 "Action": {"Block": {}},
 "VisibilityConfig": {"SampledRequestsEnabled": true, "CloudWatchMetricsEnabled": true, "MetricName": "이름"}}
```
속도 기반 규칙의 Statement: `{"RateBasedStatement": {"Limit": 횟수, "AggregateKeyType": "IP"}}`
