# 설명: InstanceId 가 없는 주소를 다 반납하면 Keep 예약 주소까지 사라진다 (NAT 주소는 InUse 로 거부됨)
# 실패해야: Keep=true 예약 주소
# 실패해야: old-batch 의 주소
aws ec2 describe-addresses --query 'Addresses[?!InstanceId].AllocationId' --output text | tr '\t' '\n' \
  | while read -r a; do aws ec2 release-address --allocation-id "$a"; done
