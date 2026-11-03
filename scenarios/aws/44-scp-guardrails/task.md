# 실험 계정에 안전 펜스 치기 (Organizations SCP)

회사 AWS 계정들은 **Organizations** 로 묶여 있어요. 운영 계정은 `Production` OU, 개발자 실험 계정들은 `Sandbox` OU 에 있어요.
지난달 Sandbox 계정에서 누가 버지니아에 GPU 서버를 켜 두고 퇴근해서 요금 폭탄을 맞았어요. 요청서는 `~/scp-request.md` 에 있어요.

**SCP(서비스 제어 정책)** 는 계정 안의 누구도(관리자 포함) **넘을 수 없는 울타리**예요. IAM 정책처럼 생겼지만 권한을 **주지는 못하고, 제한만** 해요.

## 목표
1. SCP **`sandbox-guardrails`** 를 만드세요.
   - **서울(`ap-northeast-2`) 밖** 리전으로 가는 요청은 거부. 단, 요청서의 **전역 서비스**는 예외
   - **GPU 인스턴스**(유형이 `p`·`g` 로 시작)는 서울에서도 거부. Graviton(`m7g`, `c6g`)은 막지 않기
2. **`Sandbox` OU 에만** 연결하세요.
3. 기존 SCP(`FullAWSAccess`, `deny-leave-org`)는 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws organizations list-roots` / `list-organizational-units-for-parent --parent-id r-...` | 루트, OU 목록 |
| `aws organizations list-policies --filter SERVICE_CONTROL_POLICY` | SCP 목록 |
| `aws organizations list-policies-for-target --target-id ou-... --filter SERVICE_CONTROL_POLICY` | 거기 붙은 SCP |
| `aws organizations create-policy --name 이름 --type SERVICE_CONTROL_POLICY --description 설명 --content file://scp.json` | SCP 만들기 |
| `aws organizations update-policy --policy-id p-... --content file://scp.json` | 내용 고치기 |
| `aws organizations attach-policy --policy-id p-... --target-id ou-...` | 연결 (`detach-policy` 로 떼기) |

**정책 재료**
| 쓰고 싶은 것 | 쓰는 법 |
|---|---|
| "이 서비스들 **빼고** 전부" | `"NotAction": ["iam:*", "sts:*", ...]` |
| 요청이 가는 리전 | 조건 키 `aws:RequestedRegion` |
| 켜려는 인스턴스 유형 | 조건 키 `ec2:InstanceType` (`ec2:RunInstances` 에서) |
| 같지 않으면 / 패턴이 맞으면 | `StringNotEquals` / `StringLike` (`*` 는 아무 글자) |
