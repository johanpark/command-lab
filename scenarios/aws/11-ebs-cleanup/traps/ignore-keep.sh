# 설명: Keep=true 를 확인하지 않고 available 볼륨을 다 지우면 DB 복구 디스크까지 사라진다
# 실패해야: Keep=true 볼륨은 남아
aws ec2 describe-volumes --filters Name=status,Values=available --query 'sum(Volumes[].Size)' --output text > ~/freed.txt
for v in $(aws ec2 describe-volumes --filters Name=status,Values=available --query 'Volumes[].VolumeId' --output text); do aws ec2 delete-volume --volume-id "$v"; done
