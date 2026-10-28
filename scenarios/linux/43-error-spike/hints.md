줄 맨 앞 `2026-10-28T14:03:12+09:00` 에서 `14:03` 은 12~16번째 글자, `14` 는 12~13번째 글자예요. `head -1 ~/logs/access.log | cut -c12-16` 로 확인해 보세요.
---
5xx 만: `awk '$4 >= 500' ~/logs/access.log`. 상태 코드는 4번째 칸이에요. (`grep 5` 처럼 하면 응답 시간 `500ms` 같은 것도 걸려요)
---
분 단위: `awk '$4 >= 500' ~/logs/access.log | cut -c12-16 | sort | uniq -c | sort -rn | head -3`. 맨 위가 정답 후보예요. 혹시 다른 분에 **404** 가 잔뜩 몰려 있는 것과 헷갈리지 마세요.
---
시간 단위: `awk '$4 >= 500' ~/logs/access.log | cut -c12-13 | sort | uniq -c | awk '{print $2, $1}' > ~/by_hour.txt`. `uniq -c` 는 `개수 값` 순서라서 뒤집어 줘야 해요.
