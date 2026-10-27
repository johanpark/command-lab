`diff -u ~/config-old.conf ~/config-new.conf` 를 보세요. `-` 줄만 있으면 삭제, `+` 줄만 있으면 추가, 같은 이름이 `-` 와 `+` 둘 다 있으면 **값이 바뀐** 거예요.
---
`comm` 은 두 파일이 **정렬돼 있어야** 제대로 동작해요. 먼저 `sort -u ~/all-users.txt > /tmp/all.txt`, `sort -u ~/active-users.txt > /tmp/active.txt`
---
`comm` 은 세 칸을 출력해요: 1칸 = A 에만, 2칸 = B 에만, 3칸 = 둘 다. `-23` 은 2·3칸을 숨겨서 **A 에만 있는 것**만 남겨요: `comm -23 /tmp/all.txt /tmp/active.txt > ~/dormant.txt`
---
한 줄로: `comm -23 <(sort -u ~/all-users.txt) <(sort -u ~/active-users.txt) > ~/dormant.txt`. `<(명령)` 은 명령 결과를 파일처럼 쓰게 해 줘요.
