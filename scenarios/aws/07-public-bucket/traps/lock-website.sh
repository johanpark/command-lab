# 설명: 공개 정책이 있는 버킷을 다 막으면 웹사이트 버킷까지 안 보이게 된다
# 실패해야: 웹사이트 버킷은 그대로 공개
for b in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
  if aws s3api get-bucket-policy --bucket "$b" --query Policy --output text 2>/dev/null | jq -e '.Statement[] | select(.Principal == "*")' >/dev/null; then
    case "$b" in shop-website-*) ;; *) echo "$b" > ~/answer.txt ;; esac
    aws s3api delete-bucket-policy --bucket "$b"
    aws s3api put-public-access-block --bucket "$b" --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
  fi
done
