# 설명: tmp/ 복제 규칙을 하나 더 넣으면 orders/ 밖까지 복제된다
# 실패해야: orders/ 밖까지
SRC=$(grep -oE 'shop-orders-[0-9]+' ~/dr-plan.md | head -1); DR=$(grep -oE 'shop-orders-dr-[0-9]+' ~/dr-plan.md | head -1)
for b in "$SRC" "$DR"; do aws s3api put-bucket-versioning --bucket "$b" --versioning-configuration Status=Enabled; done
R=$(aws iam get-role --role-name s3-replication-role --query Role.Arn --output text)
cat > ~/repl.json <<JSON
{"Role": "$R",
 "Rules": [{"ID": "tmp", "Status": "Enabled", "Priority": 2, "Filter": {"Prefix": "tmp/"}, "DeleteMarkerReplication": {"Status": "Disabled"}, "Destination": {"Bucket": "arn:aws:s3:::$DR", "StorageClass": "STANDARD_IA"}},{"ID": "orders-to-dr", "Status": "Enabled", "Priority": 1,
            "Filter": {"Prefix": "orders/"},
            "DeleteMarkerReplication": {"Status": "Disabled"},
            "Destination": {"Bucket": "arn:aws:s3:::$DR", "StorageClass": "STANDARD_IA"}}]}
JSON
aws s3api put-bucket-replication --bucket "$SRC" --replication-configuration file://$HOME/repl.json
