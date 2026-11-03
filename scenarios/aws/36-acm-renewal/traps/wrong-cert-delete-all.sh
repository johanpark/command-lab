# 설명: 올해(2026) 인증서를 넣어 여전히 곧 만료되고, 만료 예정 인증서를 전부 지워 운영 인증서까지 사라진다
# 실패해야: 같은 ARN 에서 새 것으로
LIMIT=$(date -d '+30 day' +%s)
aws acm list-certificates --query "CertificateSummaryList[?NotAfter<\`$LIMIT\`].DomainName" --output text | tr '\t' '\n' > ~/expiring.txt
SHOP=$(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='shop.example'].CertificateArn" --output text)
aws acm import-certificate --certificate-arn $SHOP --certificate fileb://certs/shop.example-2026.crt --private-key fileb://certs/shop.example-2026.key >/dev/null
for a in $(aws acm list-certificates --query "CertificateSummaryList[?NotAfter<\`$LIMIT\`].CertificateArn" --output text); do aws acm delete-certificate --certificate-arn $a; done
