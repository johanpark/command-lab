# 외부 감사 업체에 키 대신 역할 주기 (교차 계정 AssumeRole·외부 ID)

올해 외부 보안 감사 업체가 우리 AWS 계정을 점검해요. 작년엔 IAM 사용자를 만들어 **액세스 키**를 메일로 보냈는데, 그 키가 아직도 살아 있어요. 요청서는 `~/audit-request.md` 에 있어요.

**역할(role)** 은 키가 없는 "모자" 같은 거예요. 신뢰 정책에 적힌 주체만 이 모자를 잠깐(최대 몇 시간) 쓸 수 있고, 쓰는 동안만 임시 자격 증명이 나와요. 다른 회사 계정에 모자를 빌려줄 수도 있어요. 이걸 **교차 계정 역할**이라고 해요.

## 목표
1. 역할 **`vendor-audit`** 을 만드세요.
   - **업체 계정만** 맡을 수 있게, 그리고 약속한 **외부 ID 가 맞을 때만**
   - 권한: AWS 관리형 정책 **`SecurityAudit`** 하나만
   - 최대 세션 시간 **1시간**
2. 작년 사용자 **`vendor-audit-2025`** 의 액세스 키를 **비활성(Inactive)** 으로 바꾸세요. 사용자와 키는 지우지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws iam create-role --role-name 이름 --assume-role-policy-document file://trust.json --max-session-duration 초` | 역할 만들기 |
| `aws iam update-assume-role-policy --role-name 이름 --policy-document file://trust.json` | 신뢰 정책 고치기 |
| `aws iam update-role --role-name 이름 --max-session-duration 초` | 최대 세션 시간 고치기 |
| `aws iam attach-role-policy --role-name 이름 --policy-arn arn:aws:iam::aws:policy/정책` | 관리형 정책 붙이기 |
| `aws iam list-access-keys --user-name 이름` | 사용자의 키 목록 |
| `aws iam update-access-key --user-name 이름 --access-key-id AKIA... --status Inactive` | 키 끄기 |

신뢰 정책(`trust.json`) 의 모양:
```json
{"Version": "2012-10-17",
 "Statement": [{"Effect": "Allow",
                "Principal": {"AWS": "arn:aws:iam::계정ID:root"},
                "Action": "sts:AssumeRole",
                "Condition": {"StringEquals": {"sts:ExternalId": "약속한 값"}}}]}
```
