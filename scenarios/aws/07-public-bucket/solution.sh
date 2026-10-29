for b in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
  case "$b" in shop-website-*) continue ;; esac
  if aws s3api get-bucket-policy --bucket "$b" --query Policy --output text 2>/dev/null | jq -e '.Statement[] | select(.Principal == "*")' >/dev/null; then
    echo "$b" > ~/answer.txt
  fi
done
B=$(cat ~/answer.txt)
aws s3api delete-bucket-policy --bucket "$B"
aws s3api put-public-access-block --bucket "$B" --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
