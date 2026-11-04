# 설명: 정책만 지우고 퍼블릭 액세스 차단을 켜지 않으면 다음 실수에 또 열린다
# 실패해야: 퍼블릭 액세스 차단 네 가지
for b in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
  case "$b" in shop-website-*) continue ;; esac
  aws s3api get-bucket-policy --bucket "$b" --query Policy --output text 2>/dev/null | jq -e '.Statement[] | select(.Principal == "*")' >/dev/null && echo "$b" > ~/answer.txt
done
aws s3api delete-bucket-policy --bucket "$(cat ~/answer.txt)"
