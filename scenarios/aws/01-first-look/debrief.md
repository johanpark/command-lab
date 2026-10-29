# 해설

```bash
aws ec2 describe-instances --filters Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].InstanceId' --output text | wc -w > ~/running.txt
aws ec2 describe-instances --filters Name=tag:Name,Values=payment-api \
  --query 'Reservations[].Instances[].InstanceId' --output text > ~/answer.txt
aws s3api list-buckets --query 'Buckets[].Name' --output text | tr '\t' '\n' > ~/buckets.txt
```

## AWS CLI 의 모양
```
aws <서비스> <동작> [옵션]
aws ec2 describe-instances --filters ... --query ... --output table
```
- 서비스: `ec2`, `s3`, `s3api`, `iam`, `logs`, `secretsmanager` ...
- 동작 이름은 API 이름 그대로: `describe-*` (조회), `create-*`, `delete-*`, `run-instances`, `stop-instances` ...
- 모르면 `aws ec2 help`, `aws ec2 describe-instances help`

## --filters 와 --query 의 차이
| | `--filters` | `--query` |
|---|---|---|
| 어디서 | AWS 서버에서 거름 | 받은 결과를 내 컴퓨터에서 다듬음 |
| 문법 | `Name=...,Values=...` | JMESPath (`[]`, `[?조건]`, `.필드`) |
| 용도 | 수천 대 중 조건에 맞는 것만 받기 | 원하는 칸만 보기 좋게 |

## 출력 형식
| `--output` | 쓰임 |
|---|---|
| `json` (기본) | `jq` 로 처리, 전체 구조 보기 |
| `table` | 사람이 보기 좋게 |
| `text` | 셸 스크립트에서 `for id in $(...)` 로 쓰기 |

## 진짜 AWS 에서는
`aws configure` 로 접속 키와 리전을 설정하고, 여러 계정은 `--profile 이름` 으로 바꿔 가며 써요. 요즘은 장기 접속 키 대신 `aws sso login` 이나 EC2 의 IAM 역할(키 없이 권한)을 권장해요.
