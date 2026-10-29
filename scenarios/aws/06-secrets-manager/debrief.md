# 해설

```bash
cd ~/app
pw=$(grep '^DB_PASSWORD=' .env | cut -d= -f2-)
aws secretsmanager create-secret --name prod/shop/db \
  --secret-string "$(jq -n --arg p "$pw" '{username: "shop", password: $p}')"
sed -i '/^DB_PASSWORD=/d' .env
# start.sh 의 source ./.env 다음 줄에 추가
#   DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id prod/shop/db --query SecretString --output text | jq -r .password)
./start.sh
```

## 왜 이게 더 안전할까?
| | `.env` 평문 | Secrets Manager |
|---|---|---|
| 누가 볼 수 있나 | 서버에 들어온 누구나, 백업·이미지를 받은 누구나 | **IAM 권한**이 있는 사람·서버만 |
| 기록 | 없음 | 누가 언제 꺼냈는지 CloudTrail 에 남음 |
| 비밀번호 교체 | 서버마다 파일 고치기 | 한 곳만 바꾸면 됨, **자동 교체(rotation)** 기능 |

서버가 비밀을 꺼낼 땐 접속 키 대신 **EC2 의 IAM 역할(instance profile)** 에 `secretsmanager:GetSecretValue` 권한을 주는 게 정석이에요. 키 파일조차 서버에 둘 필요가 없어요.

## 아직 남은 숙제
- `.env` 를 예전에 Git 에 커밋했다면 **기록에 비밀번호가 남아 있어요.** 옮긴 뒤에는 **비밀번호 자체를 바꾸세요.** (Git 의 "비밀번호를 커밋해 버렸다" 시나리오 참고)
- 셸 히스토리에도 비밀번호를 친 흔적이 남을 수 있어요. 그래서 위 풀이처럼 파일에서 꺼내 변수로 넘기는 게 좋아요.

## 비슷한 서비스
| 서비스 | 특징 |
|---|---|
| SSM Parameter Store (`SecureString`) | 무료 구간이 넉넉, 설정값과 비밀을 함께 관리 |
| Secrets Manager | 자동 교체, RDS 연동 |
| HashiCorp Vault, Kubernetes Secret | AWS 밖에서도 |
