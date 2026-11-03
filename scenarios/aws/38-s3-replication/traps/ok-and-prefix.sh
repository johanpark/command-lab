# 설명: Filter 를 And 로 감싸 접두사만 써도 맞는 풀이다
# 통과해야
SRC=$(grep -oE 'shop-orders-[0-9]+' ~/dr-plan.md | head -1); DR=$(grep -oE 'shop-orders-dr-[0-9]+' ~/dr-plan.md | head -1)
for b in "$SRC" "$DR"; do aws s3api put-bucket-versioning --bucket "$b" --versioning-configuration Status=Enabled; done
R=$(aws iam get-role --role-name s3-replication-role --query Role.Arn --output text)
cat > ~/repl.json <<JSON
{"Role": "$R",
 "Rules": [{"ID": "orders-to-dr", "Status": "Enabled", "Priority": 1,
            "Filter": {"And": {"Prefix": "orders/"}},
            "DeleteMarkerReplication": {"Status": "Disabled"},
            "Destination": {"Bucket": "arn:aws:s3:::$DR", "StorageClass": "STANDARD_IA"}}]}
JSON
aws s3api put-bucket-replication --bucket "$SRC" --replication-configuration file://$HOME/repl.json
