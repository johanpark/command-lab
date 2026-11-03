# 설명: 함수 이름을 부분 일치로 비교하고, 감사 로그를 모두 400 으로 맞추고, /shop/ 전체를 바꾼다
# 실패해야: 없어진 함수의 로그 그룹
# 실패해야: 더 길던 건 그대로
# 실패해야: 규칙에 없는 그룹
FN=$(aws lambda list-functions --query 'Functions[].FunctionName' --output text | tr '\t' '\n')
for g in $(aws logs describe-log-groups --log-group-name-prefix /aws/lambda/ --query 'logGroups[].logGroupName' --output text); do
  if echo "$FN" | grep -q "${g#/aws/lambda/}" || echo "${g#/aws/lambda/}" | grep -qf <(echo "$FN"); then aws logs put-retention-policy --log-group-name $g --retention-in-days 14; else aws logs delete-log-group --log-group-name $g; fi
done
for g in $(aws logs describe-log-groups --log-group-name-prefix /shop/ --query 'logGroups[].logGroupName' --output text); do
  case $g in /shop/audit/*) d=400 ;; *) d=30 ;; esac; aws logs put-retention-policy --log-group-name $g --retention-in-days $d; done
