# 놀고 있는 서버 줄이기 (CloudWatch 지표로 인스턴스 크기 조정)

"이번 달 EC2 비용 20% 줄이기" 지시가 내려왔어요. 기준은 `~/rightsizing.md` 에 있어요.
CloudWatch 에는 서버마다 지난 7일 동안의 **CPU 사용률**이 1시간 단위로 쌓여 있어요.

## 목표
1. 각 서버의 지난 7일 CPU **평균**과 **최대**를 확인하세요.
2. 기준(평균 10% 미만 **그리고** 최대 40% 미만)에 맞는 서버만 **한 단계 작은 타입**으로 바꾸세요.
3. `DoNotResize=true` 서버는 제외하세요.
4. 작업이 끝나면 **모든 서버가 실행 중**이어야 해요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,InstanceType,Tags[?Key=='Name']\|[0].Value]" --output table` | 서버 목록 |
| `aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --dimensions Name=InstanceId,Value=i-... --start-time 시작 --end-time 끝 --period 초 --statistics Average Maximum` | 기간 통계 |
| `date -u -d '-7 day' +%FT%TZ` | 7일 전 시각 (UTC) |
| `aws ec2 stop-instances` / `wait instance-stopped` / `start-instances --instance-ids i-...` | 중지·대기·시작 |
| `aws ec2 modify-instance-attribute --instance-id i-... --instance-type '{"Value": "m5.large"}'` | 타입 변경 (중지 상태에서) |
