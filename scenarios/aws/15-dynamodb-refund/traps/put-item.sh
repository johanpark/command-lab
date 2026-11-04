# 설명: put-item 으로 상태만 넣어 덮어쓰면 total·item_count 가 사라진다
# 실패해야: 다른 속성(total, item_count)
T=$(grep -oE 'C-[0-9]+' ~/ticket.txt)
aws dynamodb query --table-name orders --key-condition-expression "customer_id = :c AND begins_with(order_id, :p)" --expression-attribute-values "{\":c\":{\"S\":\"$T\"},\":p\":{\"S\":\"2026-10\"}}" --select COUNT --query Count --output text > ~/answer.txt
L=$(aws dynamodb query --table-name orders --key-condition-expression "customer_id = :c" --expression-attribute-values "{\":c\":{\"S\":\"$T\"}}" --no-scan-index-forward --max-items 1 --query 'Items[0].order_id.S' --output text | head -1)
aws dynamodb put-item --table-name orders --item "{\"customer_id\":{\"S\":\"$T\"},\"order_id\":{\"S\":\"$L\"},\"status\":{\"S\":\"REFUNDED\"},\"refunded_at\":{\"S\":\"$(date -Is)\"}}"
