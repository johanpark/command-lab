# 해설

```bash
aws s3api put-bucket-versioning --bucket shop-orders-XXXX --versioning-configuration Status=Enabled
aws s3api put-bucket-versioning --bucket shop-orders-dr-XXXX --versioning-configuration Status=Enabled
aws s3api put-bucket-replication --bucket shop-orders-XXXX --replication-configuration file://repl.json
```
```json
{"Role": "arn:aws:iam::123456789012:role/s3-replication-role",
 "Rules": [{"ID": "orders-to-dr", "Status": "Enabled", "Priority": 1,
            "Filter": {"Prefix": "orders/"},
            "DeleteMarkerReplication": {"Status": "Disabled"},
            "Destination": {"Bucket": "arn:aws:s3:::shop-orders-dr-XXXX", "StorageClass": "STANDARD_IA"}}]}
```

## 복제가 동작하는 방식
- 규칙을 건 **뒤에** 올라온(또는 바뀐) 객체만 복제돼요. **이미 있던 파일은 복제되지 않아요.** 기존 파일까지 옮기려면 **S3 Batch Replication** 작업을 따로 돌려야 해요.
- S3 가 내 대신 복사하므로, S3 가 맡을 **IAM 역할**(신뢰 대상 `s3.amazonaws.com`)이 원본 읽기·대상 쓰기 권한을 가져야 해요.
- 버전 관리가 필수인 이유: 복제는 "버전" 단위로 일어나요.

## 삭제 마커를 복제하지 않는 이유
DR 의 목적은 "원본에 무슨 일이 생겨도 사본은 남는 것" 이에요. 삭제 마커까지 복제하면 원본에서 `aws s3 rm` 한 번에 **복제본도 같이 사라진 것처럼** 보여요. 랜섬웨어·실수 대비라면 복제본 버킷에 **Object Lock** 까지 거는 게 좋아요.

## 실무 팁
- 같은 리전 안의 복제(SRR)도 있어요. 로그를 다른 계정의 감사 버킷으로 모을 때 많이 써요.
- `ReplicationTime`(S3 RTC)을 켜면 15분 안 복제를 보장하고 지연 지표도 받을 수 있어요 (추가 요금).
- 복제 상태는 객체마다 `aws s3api head-object` 의 `ReplicationStatus` (PENDING/COMPLETED/FAILED) 로 확인해요.
