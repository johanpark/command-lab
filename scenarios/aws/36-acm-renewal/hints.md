만료 시각 `NotAfter` 는 1970년부터 센 **초** 예요. 30일 뒤를 같은 단위로: `date -d '+30 day' +%s`
`aws acm list-certificates --query "CertificateSummaryList[].[DomainName,NotAfter,InUse]" --output table`
숫자를 날짜로: `date -d @<NotAfter>`
---
JMESPath 로 바로 거르기 (숫자 비교는 백틱 리터럴):
`aws acm list-certificates --query "CertificateSummaryList[?NotAfter<\`$(date -d '+30 day' +%s)\`].DomainName" --output text`
---
교체할 파일이 맞는지 확인: `openssl x509 -in ~/certs/shop.example-2027.crt -noout -subject -enddate` (2026 파일은 지금 쓰는 옛 것)
같은 ARN 에 다시 가져오기:
`aws acm import-certificate --certificate-arn <shop.example ARN> --certificate fileb://certs/shop.example-2027.crt --private-key fileb://certs/shop.example-2027.key --certificate-chain fileb://certs/chain.crt`
---
누가 쓰는지: `aws acm describe-certificate --certificate-arn <ARN> --query Certificate.InUseBy` → `[]` 면 아무도 안 씀 → `aws acm delete-certificate --certificate-arn <ARN>`
