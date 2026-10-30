# 해설

```bash
LIMIT=$(date -d '+30 day' +%s)
aws acm list-certificates --query "CertificateSummaryList[?NotAfter<\`$LIMIT\`].DomainName" --output text   # 만료 예정
aws acm import-certificate --certificate-arn <shop ARN> \
  --certificate fileb://certs/shop.example-2027.crt --private-key fileb://certs/shop.example-2027.key \
  --certificate-chain fileb://certs/chain.crt                                                          # 같은 ARN 에 갱신본
aws acm describe-certificate --certificate-arn <old-event ARN> --query Certificate.InUseBy            # [] 확인
aws acm delete-certificate --certificate-arn <old-event ARN>
```

## 왜 "같은 ARN 에 다시 가져오기" 인가
- 로드 밸런서·CloudFront·API Gateway 는 인증서를 **ARN 으로** 가리켜요. 같은 ARN 에 새 인증서를 넣으면 쓰는 쪽은 **아무것도 안 바꿔도** 새 인증서로 바뀌어요.
- 새로 가져오기(새 ARN)를 하면 그 인증서를 쓰는 리스너를 전부 찾아서 바꿔야 하고, 하나라도 빠뜨리면 그곳은 만료돼요.

## 가져온 인증서 vs ACM 발급 인증서
| | 가져온(IMPORTED) | ACM 발급(AMAZON_ISSUED) |
|---|---|---|
| 비용 | 업체에 지불 | **무료** |
| 갱신 | **사람이 직접** (오늘처럼) | DNS 검증이면 **자동** |
| 만료 알림 | EventBridge `ACM Certificate Approaching Expiration` 이벤트 (45일 전부터) | 자동 갱신 실패 시 |

가능하면 `aws acm request-certificate --domain-name shop.example --subject-alternative-names www.shop.example --validation-method DNS` 로 발급받고 Route 53 에 검증 레코드를 두면, 이런 만료 사고가 사라져요.

## 실무 팁
- `delete-certificate` 는 쓰는 곳이 있으면 실제 AWS 에서는 `ResourceInUseException` 으로 거부돼요. 그래도 지우기 전에 `InUseBy` 를 직접 확인하는 습관을 들이세요.
- 만료 시각은 UTC 기준 초예요. 표로 볼 땐 `date -d @숫자` 로 바꿔 보세요.
