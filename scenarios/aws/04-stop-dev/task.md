# 밤에는 개발 서버 끄기 (태그로 고르기)

이번 달 AWS 요금이 예상보다 많이 나왔어요. 확인해 보니 **개발용 서버가 밤새 켜져** 있었대요. 팀 규칙은 이래요.

- 모든 서버에는 `Env` 태그가 있어요: `prod`(운영), `staging`(검증), `dev`(개발)
- 퇴근 후에는 **`Env=dev` 서버를 끈다(stop).** 지우는(terminate) 게 아니라 끄기만!
- 단, 밤새 실험을 돌리는 서버는 **`KeepRunning=true`** 태그가 붙어 있어요. 이건 **끄면 안 돼요.**

## 목표
1. 위 규칙대로 **켜져 있는 dev 서버를 끄세요.** (`KeepRunning=true` 인 것은 제외)
2. 이번에 **끈 서버 수**를 `~/stopped.txt` 에 저장하세요.
3. `prod`, `staging` 서버는 절대 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-instances --filters Name=tag:Env,Values=dev Name=instance-state-name,Values=running` | 켜진 dev 서버 |
| `--query 'Reservations[].Instances[].[InstanceId, Tags]'` | ID 와 태그 보기 |
| `--query "Reservations[].Instances[?조건].InstanceId"` | 조건으로 거르기 (JMESPath) |
| `aws ec2 stop-instances --instance-ids i-aaa i-bbb` | 끄기 (여러 개 한 번에) |
