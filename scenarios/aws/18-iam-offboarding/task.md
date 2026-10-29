# 퇴사자 계정 막기 — 지우지 말고 잠그기 (IAM)

오늘 두 사람이 퇴사했어요. 인사팀 요청과 보안팀 규칙은 `~/offboarding.txt` 에 있어요.

계정을 바로 지우면 편하지만, 나중에 "이 키로 누가 뭘 했는지" 추적하려면 **계정과 키가 남아 있어야** 해요.
그래서 **지우지 말고, 아무것도 못 하게 잠가야** 해요.

## 목표 (퇴사자 두 명 각각)
1. **콘솔 로그인 비밀번호**를 없애세요.
2. **액세스 키를 모두 비활성(Inactive)** 으로. (삭제 ❌)
3. 속한 **그룹에서 모두** 빼세요.
4. 사용자에게 직접 붙은 **관리형 정책은 떼고**, **인라인 정책은 지우세요.**
5. 태그 **`Status=offboarded`** 를 다세요.
6. 계정 자체는 **남겨 두고**, 다른 직원·서비스 계정은 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws iam list-users` / `aws iam get-login-profile --user-name 이름` | 사용자 / 콘솔 비밀번호 유무 |
| `aws iam list-access-keys --user-name 이름` | 액세스 키 |
| `aws iam list-groups-for-user --user-name 이름` | 속한 그룹 |
| `aws iam list-attached-user-policies` / `list-user-policies --user-name 이름` | 직접 붙은 관리형 / 인라인 정책 |
| `delete-login-profile`, `update-access-key --status Inactive`, `remove-user-from-group`, `detach-user-policy`, `delete-user-policy`, `tag-user` | 막기 |
