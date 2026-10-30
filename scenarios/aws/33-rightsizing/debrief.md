# 해설

```bash
S=$(date -u -d '-7 day' +%FT%TZ); E=$(date -u +%FT%TZ)
for i in $(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text); do
  echo "$i $(aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization \
    --dimensions Name=InstanceId,Value=$i --start-time $S --end-time $E --period 604800 \
    --statistics Average Maximum --query 'Datapoints[0].[Average,Maximum]' --output text)"
done
# 기준에 맞는 서버마다: 중지 → 타입 변경 → 시작
aws ec2 stop-instances --instance-ids i-... && aws ec2 wait instance-stopped --instance-ids i-...
aws ec2 modify-instance-attribute --instance-id i-... --instance-type '{"Value": "m5.large"}'
aws ec2 start-instances --instance-ids i-...
```

## 왜 평균과 최대를 같이 보나
| 서버 | 평균 | 최대 | 판단 |
|---|---|---|---|
| admin-1 | 3% | 12% | 줄이기 ✅ |
| batch-1 | 4% | 92% | **그대로** — 매일 새벽 2시간만 바쁜 배치. 줄이면 배치가 아침까지 안 끝나요 |
| legacy-erp | 2% | 8% | 그대로 — DoNotResize (라이선스) |

평균은 "대부분의 시간" 을, 최대는 "가장 힘들 때" 를 보여 줘요. 크기를 정할 때는 **가장 힘들 때도 버틸 수 있는지**가 기준이에요. 실무에서는 최대 대신 p95·p99 같은 백분위 통계(`--extended-statistics p95`)를 많이 써요.

## 타입 변경 주의
- 실제 AWS 에서는 **실행 중인 서버의 타입은 바꿀 수 없어요** (`IncorrectInstanceState`). 중지가 필요하고, 그동안 서비스가 멈춰요. 로드 밸런서 뒤의 서버라면 한 대씩 빼고 바꿔요.
- 중지하면 **퍼블릭 IP 가 바뀌고**(Elastic IP 제외), 인스턴스 스토어 디스크의 데이터는 사라져요.
- 메모리 사용률은 CloudWatch 기본 지표에 없어요. CloudWatch Agent 를 설치해야 메모리까지 보고 판단할 수 있어요.

## 실무 팁
- **AWS Compute Optimizer** 가 이 분석을 자동으로 해서 "이 서버는 m5.large 로" 같은 추천을 줘요.
- 크기를 줄이는 것보다 큰 절감은 **Savings Plans / 예약 인스턴스**, 그리고 개발 서버를 밤에 끄는 것(이전 실습)이에요.
