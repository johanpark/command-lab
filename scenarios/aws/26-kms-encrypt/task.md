# 결제 설정 파일 암호화하고 키 관리하기 (KMS)

보안 점검에서 `~/payment-config.json` 에 **결제 대행사 비밀 키가 평문으로** 들어 있다는 지적을 받았어요.
**KMS(Key Management Service)** 키로 암호화해서, 그 키를 쓸 권한이 있는 사람·서버만 풀 수 있게 만들어요.

## 목표
1. 결제 전용 KMS 키를 새로 만들고 별칭 **`alias/payments`** 를 붙이세요.
2. 그 키에 **자동 키 교체(rotation)** 를 켜세요.
3. `~/payment-config.json` 을 그 키로 암호화해서 **`~/payment-config.json.enc`** 로 저장하고, **평문 파일은 지우세요.**
4. 더 이상 안 쓰는 **테스트용 키**(태그 `Purpose=test`)는 **7일 뒤 삭제되도록 예약**하세요. 다른 키는 그대로.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws kms list-keys` / `aws kms describe-key --key-id ID` | 키 목록 / 키 정보 |
| `aws kms list-aliases` / `aws kms list-resource-tags --key-id ID` | 별칭 / 태그 |
| `aws kms create-key --description "설명"` | 키 만들기 |
| `aws kms create-alias --alias-name alias/이름 --target-key-id ID` | 별칭 붙이기 |
| `aws kms enable-key-rotation --key-id ID` | 자동 교체 켜기 (**별칭이 아니라 키 ID** 로!) |
| `aws kms encrypt --key-id alias/payments --plaintext fileb://파일 --query CiphertextBlob --output text` | 암호화 (결과는 base64) |
| `aws kms decrypt --ciphertext-blob fileb://파일.enc --query Plaintext --output text` | 복호화 확인 (결과는 base64) |
| `aws kms schedule-key-deletion --key-id ID --pending-window-in-days 7` | 삭제 예약 |
