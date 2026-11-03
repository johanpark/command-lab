# 설명: FullAWSAccess 를 떼면 Sandbox 계정은 아무것도 못 한다
# 모범 풀이 먼저
# 실패해야: FullAWSAccess
# 실패해야: 평범한 작업
SBX=$(aws organizations list-organizational-units-for-parent --parent-id "$(aws organizations list-roots --query 'Roots[0].Id' --output text)" --query "OrganizationalUnits[?Name=='Sandbox'].Id" --output text)
aws organizations detach-policy --policy-id p-FullAWSAccess --target-id "$SBX"
