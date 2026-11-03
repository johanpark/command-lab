# 설명: 이름순 최근 3개만 남기면 시작 템플릿이 쓰는 AMI 까지 지워지고, 스냅샷은 남는다
# 실패해야: 남겨야 할 AMI
# 실패해야: 스냅샷까지 지웠다
KEEP=$(aws ec2 describe-images --owners self --filters 'Name=name,Values=web-*' --query 'sort_by(Images,&Name)[-3:].ImageId' --output text)
for a in $(aws ec2 describe-images --owners self --filters 'Name=name,Values=web-*' --query 'Images[].ImageId' --output text); do
  [[ " $(echo $KEEP) " == *" $a "* ]] || aws ec2 deregister-image --image-id $a; done
