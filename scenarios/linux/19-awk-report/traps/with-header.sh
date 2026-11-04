# 설명: NR > 1 을 빼면 머리글 줄(category)까지 집계된다
# 실패해야: 머리글 줄 'category'
awk -F, '{ s[$2] += $4 * $5 } END { for (c in s) print c, s[c] }' ~/sales.csv | sort -k2 -nr > ~/report.txt
awk -F, 'NR > 1 { q[$3] += $4 } END { for (i in q) print q[i], i }' ~/sales.csv | sort -nr | head -n 1 | cut -d' ' -f2 > ~/answer.txt
