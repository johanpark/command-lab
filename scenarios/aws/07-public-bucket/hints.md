버킷마다 정책을 하나씩 보세요:
```
for b in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
  echo "== $b"; aws s3api get-bucket-policy --bucket $b --query Policy --output text 2>/dev/null | jq -c '.Statement[] | {Principal, Action}'
done
```
`"Principal": "*"` 인 버킷이 공개 버킷이에요.
---
공개 버킷이 두 개 나오죠? 하나는 웹사이트(원래 공개), 다른 하나가 사고예요. 이름과 안에 든 파일(`aws s3 ls s3://버킷/`)을 보면 구별돼요.
---
막기: `aws s3api delete-bucket-policy --bucket 사고버킷` → `aws s3api put-public-access-block --bucket 사고버킷 --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true`
---
웹사이트 버킷에 퍼블릭 액세스 차단을 켜면 **웹사이트가 안 보여요!** 차단은 사고 버킷에만. 확인: `aws s3api get-public-access-block --bucket 사고버킷`
