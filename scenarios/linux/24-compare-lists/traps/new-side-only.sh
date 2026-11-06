# 설명: diff 의 > 쪽만 보면 새로 추가된 설정까지 '바뀐 것' 으로 센다
# 실패해야: 값이 바뀐 설정 이름
diff ~/config-old.conf ~/config-new.conf | grep '^>' | cut -d' ' -f2 > ~/changed.txt
comm -23 <(sort -u ~/all-users.txt) <(sort -u ~/active-users.txt) > ~/dormant.txt
