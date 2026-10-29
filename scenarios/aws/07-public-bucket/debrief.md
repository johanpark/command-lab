# 해설

```bash
B=customer-exports-1234        # 사고 버킷
aws s3api get-bucket-policy --bucket $B --query Policy --output text | jq .
echo $B > ~/answer.txt
aws s3api delete-bucket-policy --bucket $B
aws s3api put-public-access-block --bucket $B --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

## 버킷이 공개되는 두 가지 길
| 길 | 모양 | 막는 차단 옵션 |
|---|---|---|
| 버킷 정책 | `"Principal": "*"` + `s3:GetObject` | BlockPublicPolicy, RestrictPublicBuckets |
| ACL | `AllUsers` 에 READ (`--acl public-read`) | BlockPublicAcls, IgnorePublicAcls |

**퍼블릭 액세스 차단**은 이 둘을 한꺼번에 무시하게 하는 안전장치예요. 버킷마다, 또는 **계정 전체**(`aws s3control put-public-access-block`)에 걸 수 있어요. 2023년부터 새 버킷은 기본으로 켜져 있어요.

## 웹사이트는 어떻게?
요즘은 웹사이트 버킷도 공개하지 않고, **CloudFront** 만 버킷을 읽을 수 있게(OAC) 한 뒤 손님은 CloudFront 로만 들어오게 해요. 그러면 모든 버킷에 차단을 켤 수 있어요.

## 사고 뒤에 할 일
1. **언제부터 누가 받아 갔는지**: S3 서버 액세스 로그, CloudTrail 데이터 이벤트
2. 개인정보가 나갔다면 **신고 의무**를 확인 (개인정보보호법)
3. 재발 방지: AWS Config 규칙 `s3-bucket-public-read-prohibited`, IAM Access Analyzer 로 공개 자원 자동 탐지
