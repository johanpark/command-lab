먼저 요청서에서 두 값을 찾아 두세요: 업체 계정 ID(12자리 숫자)와 외부 ID. 문제 본문의 `trust.json` 모양에 그대로 넣으면 돼요.
---
`"Principal": {"AWS": "arn:aws:iam::업체계정ID:root"}` 의 `root` 는 "그 계정의 루트 사용자" 가 아니라 **그 계정 전체**를 뜻해요. 업체 쪽에서 누가 맡을지는 업체 관리자가 자기 계정 IAM 으로 정해요.
⚠️ `"Principal": "*"` 나 `{"AWS": "*"}` 는 **세상 모든 AWS 계정**이에요. 외부 ID 하나만 알면 아무나 들어와요.
---
역할 만들기: `aws iam create-role --role-name vendor-audit --assume-role-policy-document file://trust.json --max-session-duration 3600`
권한: `aws iam attach-role-policy --role-name vendor-audit --policy-arn arn:aws:iam::aws:policy/SecurityAudit`
이미 만들었는데 틀렸다면 `update-assume-role-policy`, `update-role --max-session-duration` 으로 고쳐요. 확인: `aws iam get-role --role-name vendor-audit`
---
작년 키: `aws iam list-access-keys --user-name vendor-audit-2025` 로 키 ID 를 보고 `aws iam update-access-key --user-name vendor-audit-2025 --access-key-id AKIA... --status Inactive`. `delete-access-key` 나 `delete-user` 는 쓰지 마세요.
