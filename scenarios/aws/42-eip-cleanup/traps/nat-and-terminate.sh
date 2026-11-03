# 설명: NAT 주소를 떼고, 폐기 예정 서버를 지금 지워 버린다
# 모범 풀이 먼저
# 실패해야: NAT 게이트웨이 주소
# 실패해야: old-batch 서버는 그대로다
N=$(aws ec2 describe-addresses --query "Addresses[?Tags[?Value=='nat-gw-eip']].AssociationId" --output text); aws ec2 disassociate-address --association-id $N
OB=$(aws ec2 describe-instances --filters Name=tag:Name,Values=old-batch --query 'Reservations[0].Instances[0].InstanceId' --output text); aws ec2 terminate-instances --instance-ids $OB
