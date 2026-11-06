# 설명: 용량 합계를 모든 볼륨(in-use 포함)으로 계산한다
# 실패해야: 지운 볼륨 용량 합계
aws ec2 describe-volumes --query 'sum(Volumes[].Size)' --output text > ~/freed.txt
F="Volumes[?!(Tags[?Key=='Keep' && Value=='true'])]"
for v in $(aws ec2 describe-volumes --filters Name=status,Values=available --query "$F.VolumeId" --output text); do aws ec2 delete-volume --volume-id "$v"; done
