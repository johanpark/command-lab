LIMIT=$(date -d '+30 day' +%s)
aws acm list-certificates --query "CertificateSummaryList[?NotAfter<\`$LIMIT\`].DomainName" --output text | tr '\t' '\n' > ~/expiring.txt
SHOP=$(aws acm list-certificates --query "CertificateSummaryList[?DomainName=='shop.example'].CertificateArn" --output text)
aws acm import-certificate --certificate-arn "$SHOP" --certificate fileb://$HOME/certs/shop.example-2027.crt \
  --private-key fileb://$HOME/certs/shop.example-2027.key --certificate-chain fileb://$HOME/certs/chain.crt >/dev/null
for a in $(aws acm list-certificates --query "CertificateSummaryList[?NotAfter<\`$LIMIT\`].CertificateArn" --output text); do
  [ "$(aws acm describe-certificate --certificate-arn "$a" --query 'length(Certificate.InUseBy)' --output text)" = 0 ] \
    && aws acm delete-certificate --certificate-arn "$a"
done
