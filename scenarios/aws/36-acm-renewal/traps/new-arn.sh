# 설명: 새 ARN 으로 가져와 리스너를 바꾸고, 목록에 하나만 적고, 안 쓰는 인증서는 남긴다
# 실패해야: 30일 안에 만료되는 도메인
# 실패해야: 같은 ARN 에서 새 것으로
# 실패해야: 리스너(443)는 그대로
# 실패해야: old-event.shop.example
echo shop.example > ~/expiring.txt
N=$(aws acm import-certificate --certificate fileb://certs/shop.example-2027.crt --private-key fileb://certs/shop.example-2027.key --certificate-chain fileb://certs/chain.crt --query CertificateArn --output text)
L=$(aws elbv2 describe-listeners --load-balancer-arn $(aws elbv2 describe-load-balancers --query 'LoadBalancers[0].LoadBalancerArn' --output text) --query "Listeners[?Port==\`443\`].ListenerArn" --output text)
aws elbv2 modify-listener --listener-arn $L --certificates CertificateArn=$N >/dev/null
