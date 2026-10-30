# 서버에 박힌 액세스 키를 IAM 역할로 바꾸기 (인스턴스 프로파일)

보안 점검에서 EC2 `report-server` 의 설정 파일(`~/report-server/.env`)에 **IAM 사용자 액세스 키가 평문으로** 들어 있다는 지적을 받았어요.
키는 파일이 유출되면 그대로 쓰일 수 있고, 만료도 없어요. EC2 에서는 **IAM 역할**을 서버에 붙이면 키 없이 같은 권한을 쓸 수 있어요 (AWS CLI·SDK 가 자동으로 임시 자격 증명을 받아 옴).

## 목표
1. EC2 가 맡을 수 있는 IAM 역할 **`report-server-role`** 을 만드세요. (신뢰 정책: `ec2.amazonaws.com`)
2. 역할에 **report-bot 과 같은 권한**을 주세요. (`~/report-server/README.md` 참고. 더 넓게 주지 마세요)
3. 인스턴스 프로파일 **`report-server-profile`** 에 역할을 넣고, `report-server` 인스턴스에 **연결**하세요.
4. `.env` 에서 **AWS 액세스 키 두 줄만 지우세요.** (다른 설정은 그대로)
5. report-bot 의 액세스 키를 **비활성화**하세요. (삭제는 아직 ❌ — 혹시 다른 곳에서 쓰는지 며칠 지켜본 뒤에)

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws iam list-attached-user-policies` / `list-user-policies` / `get-user-policy --user-name report-bot ...` | 지금 권한 |
| `aws iam create-role --role-name 이름 --assume-role-policy-document file://trust.json` | 역할 만들기 |
| `aws iam attach-role-policy` / `put-role-policy --role-name 이름 ...` | 역할에 권한 |
| `aws iam create-instance-profile --instance-profile-name 이름` | 인스턴스 프로파일 |
| `aws iam add-role-to-instance-profile --instance-profile-name 이름 --role-name 역할` | 프로파일에 역할 넣기 |
| `aws ec2 associate-iam-instance-profile --instance-id i-... --iam-instance-profile Name=이름` | 서버에 연결 |
| `aws iam update-access-key --user-name report-bot --access-key-id AKIA... --status Inactive` | 키 비활성화 |
