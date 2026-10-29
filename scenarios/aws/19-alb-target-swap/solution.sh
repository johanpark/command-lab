P=$(grep -oE '\*\*[0-9]+ 포트' ~/deploy.md | grep -oE '[0-9]+')
HP=$(grep -oE '헬스 체크 주소는 \*\*[^*]+' ~/deploy.md | sed 's/.*\*\*//')
TG=$(aws elbv2 describe-target-groups --names web-tg --query 'TargetGroups[0].TargetGroupArn' --output text)
V2=$(aws ec2 describe-instances --filters Name=tag:Version,Values=v2 Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId' --output text)
aws elbv2 register-targets --target-group-arn "$TG" --targets $(for i in $V2; do echo "Id=$i,Port=$P"; done)
aws elbv2 modify-target-group --target-group-arn "$TG" --health-check-path "$HP" >/dev/null
V1=$(aws ec2 describe-instances --filters Name=tag:Version,Values=v1 --query 'Reservations[].Instances[].InstanceId' --output text)
aws elbv2 deregister-targets --target-group-arn "$TG" --targets $(for i in $V1; do echo "Id=$i"; done)
