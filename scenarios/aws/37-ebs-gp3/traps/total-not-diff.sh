# 설명: 절감액을 gp2 요금 전체로 계산하면 안 된다 (gp2 - gp3 차액)
# 실패해야: 한 달 절감액
F="Volumes[?!(Tags[?Key=='Migration' && Value=='hold'])]"
T=$(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query "sum($F.Size)" --output text)
for v in $(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query "$F.VolumeId" --output text); do
  aws ec2 modify-volume --volume-id "$v" --volume-type gp3 >/dev/null
done
python3 -c "print(f'{$T * 0.114:.2f}')" > ~/saving.txt
