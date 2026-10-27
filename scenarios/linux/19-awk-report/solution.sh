awk -F, 'NR > 1 { s[$2] += $4 * $5 } END { for (c in s) print c, s[c] }' ~/sales.csv | sort -k2 -nr > ~/report.txt
awk -F, 'NR > 1 { q[$3] += $4 } END { for (i in q) print q[i], i }' ~/sales.csv | sort -nr | head -n 1 | cut -d' ' -f2 > ~/answer.txt
