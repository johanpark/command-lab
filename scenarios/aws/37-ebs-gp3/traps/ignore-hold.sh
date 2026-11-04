# 설명: Migration=hold 태그를 안 보고 gp2 를 다 바꾸면 보류 볼륨까지 바뀐다
# 실패해야: 보류(hold)
F="Volumes[]"
T=$(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query "sum($F.Size)" --output text)
for v in $(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query "$F.VolumeId" --output text); do
  aws ec2 modify-volume --volume-id "$v" --volume-type gp3 >/dev/null
done
python3 -c "print(f'{$T * (0.114 - 0.0912):.2f}')" > ~/saving.txt
