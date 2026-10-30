# 해설

```bash
IPARN=$(aws wafv2 create-ip-set --name blocked-ips --scope REGIONAL --ip-address-version IPV4 \
  --addresses 45.x.x.17/32 45.x.x.18/32 185.x.x.0/24 91.x.x.x/32 --query Summary.ARN --output text)
ACL=$(aws wafv2 create-web-acl --name shop-waf --scope REGIONAL --default-action Allow={} --rules file://rules.json \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=shop-waf --query Summary.ARN --output text)
aws wafv2 associate-web-acl --web-acl-arn $ACL --resource-arn <shop-alb ARN>
```

## WAF 의 구조
```
요청 ─▶ [웹 ACL shop-waf]  규칙을 Priority 순서대로 검사
          0. blocked-ips 에 있나?        → 있으면 Block (끝)
          1. 이 IP 가 5분에 N번 넘었나?  → 넘으면 Block (끝)
          (아무 규칙에도 안 걸림)        → 기본 동작 Allow
       ─▶ ALB ─▶ 서버
```
- **기본 동작**을 Block 으로 하면 규칙에 안 걸린 정상 손님까지 다 막혀요. 공개 사이트는 보통 Allow + 차단 규칙.
- 속도 기반 규칙은 **최근 5분**(기본) 동안 IP 별 요청 수를 세서, 넘은 IP 를 넘은 동안만 막아요. 공격자가 멈추면 자동으로 풀려요.

## 사무실 IP 를 빼는 이유
분석 결과만 보고 실패가 많은 IP 를 다 막으면, 자동 테스트를 돌리던 회사 사무실이 막혀서 **배포 검증이 멈춰요.** 차단 전에 "우리 쪽 IP 인지" 확인하는 습관이 중요해요. 필요하면 사무실 IP 를 **허용(Allow) 규칙**으로 가장 앞에 두기도 해요.

## 실무 팁
- 처음엔 차단 대신 **Count** 동작으로 걸어 두고, 정상 요청이 걸리지 않는지 며칠 본 뒤 Block 으로 바꾸면 안전해요.
- 직접 규칙을 다 만들기보다 AWS 관리형 규칙(`AWSManagedRulesCommonRuleSet`, `AWSManagedRulesATPRuleSet`=계정 탈취 방지)을 함께 쓰는 게 일반적이에요.
- 속도 제한에 `ScopeDownStatement` 를 붙이면 `/login` 경로에만 더 엄격한 한도를 걸 수 있어요.
