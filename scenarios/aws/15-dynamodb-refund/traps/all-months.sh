# 설명: begins_with 조건 없이 세면 10월이 아니라 모든 주문 수가 된다
# 실패해야: 10월 주문 건수
T=$(grep -oE 'C-[0-9]+' ~/ticket.txt)
aws dynamodb query --table-name orders --key-condition-expression "customer_id = :c" --expression-attribute-values "{\":c\":{\"S\":\"$T\"}}" --select COUNT --query Count --output text > ~/answer.txt
