# 해설

```bash
TG=$(aws elbv2 describe-target-groups --names web-tg --query 'TargetGroups[0].TargetGroupArn' --output text)
V2=$(aws ec2 describe-instances --filters Name=tag:Version,Values=v2 Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].InstanceId' --output text)
aws elbv2 register-targets --target-group-arn $TG --targets $(for i in $V2; do echo Id=$i,Port=8080; done)
aws elbv2 modify-target-group --target-group-arn $TG --health-check-path /healthz
# (실제로는 여기서 describe-target-health 가 healthy 가 될 때까지 기다린다)
V1=$(aws ec2 describe-instances --filters Name=tag:Version,Values=v1 --query 'Reservations[].Instances[].InstanceId' --output text)
aws elbv2 deregister-targets --target-group-arn $TG --targets $(for i in $V1; do echo Id=$i; done)
```

## 로드 밸런서의 구조
```
사용자 → ALB(shop-alb) → 리스너(:80) → 대상 그룹(web-tg) → 서버들(각자 포트)
                                         └ 헬스 체크: 서버마다 /healthz 를 주기적으로 호출
```
- 헬스 체크에 실패한 서버(`unhealthy`)에는 트래픽을 보내지 않아요. 경로를 v2 에 맞게 안 바꾸면 **v2 서버가 전부 unhealthy** 가 되고, v1 을 빼는 순간 **서비스 전체가 503** 이 돼요.
- 서버마다 포트를 따로 줄 수 있어서, 대상 그룹의 기본 포트(80)와 앱 포트가 달라도 돼요.

## 무중단 교체 순서
1. 새 서버 **등록** → 2. `healthy` **확인** → 3. 옛 서버 **빼기** → 4. (하루쯤 뒤) 옛 서버 정리
- 빼는(deregister) 순간 바로 끊기지 않고 **연결 드레이닝**(`deregistration_delay`, 기본 300초) 동안 처리 중인 요청을 마무리해요.
- 문제가 생기면 반대로 v1 을 다시 등록하고 v2 를 빼면 되돌아가요. 그래서 옛 서버를 바로 지우지 않아요.

## 실무 팁
- 이 과정을 손으로 하는 대신 **Auto Scaling 그룹의 인스턴스 새로 고침**, **CodeDeploy 블루/그린**, ECS 롤링 배포가 같은 일을 자동으로 해 줘요.
- 블루/그린은 대상 그룹을 두 개 두고 **리스너가 가리키는 대상 그룹을 바꾸는** 방식이라, 되돌리기가 한 번의 명령이에요.
