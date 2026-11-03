# 설명: 접두사를 orders/2026/ 으로 좁히면 다른 주문 기록은 복제되지 않는다
# 실패해야: 주문 기록 일부만
SRC=$(grep -oE 'shop-orders-[0-9]+' ~/dr-plan.md | head -1); DR=$(grep -oE 'shop-orders-dr-[0-9]+' ~/dr-plan.md | head -1)
for b in "$SRC" "$DR"; do aws s3api put-bucket-versioning --bucket "$b" --versioning-configuration Status=Enabled; done
R=$(aws iam get-role --role-name s3-replication-role --query Role.Arn --output text)
cat > ~/repl.json <<JSON
{"Role": "$R",
 "Rules": [{"ID": "orders-to-dr", "Status": "Enabled", "Priority": 1,
            "Filter": {"Prefix": "orders/2026/"},
            "DeleteMarkerReplication": {"Status": "Disabled"},
            "Destination": {"Bucket": "arn:aws:s3:::$DR", "StorageClass": "STANDARD_IA"}}]}
JSON
aws s3api put-bucket-replication --bucket "$SRC" --replication-configuration file://$HOME/repl.json
