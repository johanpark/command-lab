# 설명: comm 은 정렬된 입력이 필요하다. 정렬 없이 비교하면 결과가 틀린다
# 실패해야: 휴면 아이디가 정렬·중복 없이
diff ~/config-old.conf ~/config-new.conf | grep '^<' | cut -d' ' -f2 | sort > /tmp/old-keys
diff ~/config-old.conf ~/config-new.conf | grep '^>' | cut -d' ' -f2 | sort > /tmp/new-keys
comm -12 /tmp/old-keys /tmp/new-keys > ~/changed.txt
comm -23 ~/all-users.txt ~/active-users.txt > ~/dormant.txt 2>/dev/null
