# 설명: sort -k2 -n 은 작은 순서라 큰 순서가 아니다
# 실패해야: 큰 순서로 있다
awk -F, 'NR > 1 { s[$2] += $4 * $5 } END { for (c in s) print c, s[c] }' ~/sales.csv | sort -k2 -n > ~/report.txt
awk -F, 'NR > 1 { q[$3] += $4 } END { for (i in q) print q[i], i }' ~/sales.csv | sort -nr | head -n 1 | cut -d' ' -f2 > ~/answer.txt
