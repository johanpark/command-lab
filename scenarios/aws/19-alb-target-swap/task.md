# 로드 밸런서 뒤 서버를 새 버전으로 교체 (ALB 대상 그룹)

쇼핑몰 웹은 로드 밸런서 `shop-alb` 뒤의 **대상 그룹 `web-tg`** 에 등록된 서버들이 처리해요.
오늘 새 버전(v2) 서버로 바꾸는 날이에요. 체크리스트는 `~/deploy.md` 에 있어요.

## 목표
1. `web-tg` 에 **실행 중인 v2 서버**들을 **v2 앱 포트로** 등록하세요.
2. 대상 그룹의 **헬스 체크 경로**를 v2 앱에 맞게 바꾸세요.
3. **v1 서버는 대상 그룹에서 빼세요.** 단, 서버 자체는 켜 둔 채로 (되돌리기용).
4. 결과적으로 `web-tg` 에는 **v2 서버들만** 남아야 해요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws elbv2 describe-target-groups --names web-tg` | 대상 그룹 정보 (ARN, 헬스 체크 설정) |
| `aws elbv2 describe-target-health --target-group-arn ARN` | 등록된 서버와 상태 |
| `aws elbv2 register-targets --target-group-arn ARN --targets Id=i-...,Port=포트 Id=i-...,Port=포트` | 등록 |
| `aws elbv2 deregister-targets --target-group-arn ARN --targets Id=i-...` | 빼기 |
| `aws elbv2 modify-target-group --target-group-arn ARN --health-check-path /경로` | 헬스 체크 경로 |
