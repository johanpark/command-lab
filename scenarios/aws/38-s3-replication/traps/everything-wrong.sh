# 설명: 원본만 버전 관리, 다른 역할, 버킷 전체 복제, 기본 저장 클래스, 삭제 마커 복제
# 실패해야: 버전 관리가 켜져
# 실패해야: s3-replication-role
# 실패해야: orders/ 밖까지
# 실패해야: STANDARD_IA
# 실패해야: 삭제 마커
SRC=$(grep -oE 'shop-orders-[0-9]+' ~/dr-plan.md | head -1); DR=$(grep -oE 'shop-orders-dr-[0-9]+' ~/dr-plan.md | head -1)
aws s3api put-bucket-versioning --bucket $SRC --versioning-configuration Status=Enabled
echo "{\"Role\":\"arn:aws:iam::123456789012:role/ec2-backup-role\",\"Rules\":[{\"Status\":\"Enabled\",\"Priority\":1,\"Filter\":{},\"DeleteMarkerReplication\":{\"Status\":\"Enabled\"},\"Destination\":{\"Bucket\":\"arn:aws:s3:::$DR\"}}]}" > r.json
aws s3api put-bucket-replication --bucket $SRC --replication-configuration file://r.json
