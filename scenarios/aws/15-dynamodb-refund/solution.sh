T=$(grep -oE 'C-[0-9]+' ~/ticket.txt)
aws dynamodb query --table-name orders --key-condition-expression "customer_id = :c AND begins_with(order_id, :p)" \
  --expression-attribute-values "{\":c\":{\"S\":\"$T\"},\":p\":{\"S\":\"2026-10\"}}" --select COUNT --query Count --output text > ~/answer.txt
L=$(aws dynamodb query --table-name orders --key-condition-expression "customer_id = :c" \
  --expression-attribute-values "{\":c\":{\"S\":\"$T\"}}" --no-scan-index-forward --max-items 1 --query 'Items[0].order_id.S' --output text | head -1)
aws dynamodb update-item --table-name orders \
  --key "{\"customer_id\":{\"S\":\"$T\"},\"order_id\":{\"S\":\"$L\"}}" \
  --update-expression "SET #s = :r, refunded_at = :t" --condition-expression "#s = :p" \
  --expression-attribute-names '{"#s":"status"}' \
  --expression-attribute-values "{\":r\":{\"S\":\"REFUNDED\"},\":p\":{\"S\":\"PAID\"},\":t\":{\"S\":\"$(date -Is)\"}}"
