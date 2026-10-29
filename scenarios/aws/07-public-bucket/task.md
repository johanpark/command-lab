# 실수로 공개된 S3 버킷 찾아 막기

외부 보안 연구자에게서 메일이 왔어요.

> 귀사의 S3 버킷 하나에서 **고객 주문 내역 파일**을 누구나 내려받을 수 있습니다. 확인 부탁드립니다.

버킷을 인터넷에 공개하는 가장 흔한 실수는 **버킷 정책(bucket policy)** 에 `"Principal": "*"` (아무나) 를 넣는 거예요.

## 목표
1. **공개되면 안 되는데 공개된 버킷** 이름을 `~/answer.txt` 에 저장하세요.
   - 정적 웹사이트 버킷(`shop-website-...`)은 **원래 공개가 맞아요.** 손님이 웹사이트를 봐야 하니까요.
2. 그 버킷을 **비공개로** 만드세요.
   - 공개 버킷 정책을 지우고
   - 다시 실수해도 막히도록 **퍼블릭 액세스 차단(Block Public Access)** 네 가지를 모두 켜세요.
3. 웹사이트 버킷과 다른 버킷은 **건드리지 마세요.**

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws s3 ls` | 버킷 목록 |
| `aws s3api get-bucket-policy --bucket 이름 --query Policy --output text` | 버킷 정책 (없으면 NoSuchBucketPolicy 에러) |
| `... \| jq .` | 정책 JSON 보기 좋게 |
| `aws s3api delete-bucket-policy --bucket 이름` | 정책 지우기 |
| `aws s3api put-public-access-block --bucket 이름 --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true` | 퍼블릭 액세스 차단 |
| `aws s3api get-public-access-block --bucket 이름` | 차단 설정 확인 |
