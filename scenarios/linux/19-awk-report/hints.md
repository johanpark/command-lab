먼저 한 칸씩 뽑아 보세요: `awk -F, '{print $2, $4 * $5}' ~/sales.csv | head`. 첫 줄이 이상하죠? 머리글이에요.
---
`NR > 1` 로 머리글을 건너뛰고, 카테고리를 키로 더하기: `awk -F, 'NR > 1 { s[$2] += $4 * $5 } END { for (c in s) print c, s[c] }' ~/sales.csv`
---
`for (c in s)` 의 출력 순서는 뒤죽박죽이에요. `| sort -k2 -nr` 로 매출 순 정렬 후 `> ~/report.txt`
---
2번은 같은 방식으로 키를 `$3`(상품), 값을 `$4`(수량)로: `awk -F, 'NR > 1 { q[$3] += $4 } END { for (i in q) print q[i], i }' ~/sales.csv | sort -nr | head -n 1`
