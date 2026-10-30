# 인증서 만료 12일 전! 찾아서 교체하기 (ACM)

"인증서가 곧 만료됩니다" 라는 메일이 왔어요. HTTPS 인증서가 만료되면 브라우저가 **"안전하지 않은 사이트"** 경고를 띄워서 손님이 아무도 못 들어와요.
이 회사 인증서는 외부 업체에서 사서 **ACM 에 가져오기(import)** 한 것이라, ACM 이 자동으로 갱신해 주지 않아요.

## 목표
1. **30일 안에 만료되는** 인증서의 도메인 이름을 `~/expiring.txt` 에 한 줄에 하나씩 적으세요.
2. `shop.example` 인증서를 업체가 보내 준 새 인증서(`~/certs/`)로 교체하세요.
   **같은 인증서 ARN 에 다시 가져오기** 해서, 로드 밸런서 설정은 건드리지 않아야 해요.
3. 30일 안에 만료되는데 **아무 로드 밸런서도 쓰지 않는** 인증서는 지우세요.
4. 나머지 인증서는 그대로 두세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws acm list-certificates --query "CertificateSummaryList[].[DomainName,NotAfter,InUse,CertificateArn]" --output table` | 인증서 목록 (NotAfter = 만료 시각, 초 단위 숫자) |
| `aws acm describe-certificate --certificate-arn ARN` | 자세히 (`InUseBy` = 쓰는 곳) |
| `date -d @1794347702` / `date -d '+30 day' +%s` | 숫자 시각 ↔ 날짜 |
| `aws acm import-certificate --certificate-arn 기존ARN --certificate fileb://새.crt --private-key fileb://새.key --certificate-chain fileb://chain.crt` | 같은 ARN 에 새 인증서 넣기 |
| `aws acm delete-certificate --certificate-arn ARN` | 지우기 |
| `openssl x509 -in 파일.crt -noout -subject -enddate` | 인증서 파일 내용 보기 |
