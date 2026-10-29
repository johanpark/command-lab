# 해설

```bash
ids=$(aws ec2 describe-instances \
  --filters Name=tag:Env,Values=dev Name=instance-state-name,Values=running \
  --query "Reservations[].Instances[?!(Tags[?Key=='KeepRunning' && Value=='true'])].InstanceId" \
  --output text)
echo "$ids"                       # 끄기 전에 꼭 눈으로 확인
aws ec2 stop-instances --instance-ids $ids
echo $ids | wc -w > ~/stopped.txt
```

## stop vs terminate
| | stop | terminate |
|---|---|---|
| 서버 | 꺼짐, 다시 켤 수 있음 | **영구 삭제** |
| 디스크(EBS) | 남음 (저장 요금은 계속) | 기본 설정이면 같이 삭제 |
| 요금 | 컴퓨팅 요금 멈춤 | 전부 멈춤 |

밤에 끄는 건 항상 **stop**. terminate 는 되돌릴 수 없어요.

## JMESPath 조건 문법
| 식 | 뜻 |
|---|---|
| `[?State.Name=='running']` | 조건에 맞는 것만 |
| `Tags[?Key=='Env']\|[0].Value` | Env 태그 값 |
| `[?!(조건)]` | 조건에 **안** 맞는 것 |
| `&&`, `\|\|` | 그리고, 또는 |

## 자동으로 하려면
매일 손으로 하면 언젠가 잊어요. 실무에서는
- **EventBridge 스케줄러** + Lambda (또는 AWS Instance Scheduler) 로 정해진 시간에 자동 stop/start
- 태그 규칙을 문서로 정해 두고, 태그 없는 서버는 **AWS Config** 로 찾아내기
- 개발 서버는 아예 **Auto Scaling 그룹의 희망 개수를 밤에 0** 으로
