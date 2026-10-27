# 해설

```bash
awk -F, 'NR > 1 { s[$2] += $4 * $5 } END { for (c in s) print c, s[c] }' ~/sales.csv \
  | sort -k2 -nr > ~/report.txt

awk -F, 'NR > 1 { q[$3] += $4 } END { for (i in q) print q[i], i }' ~/sales.csv \
  | sort -nr | head -n 1
```

## awk 프로그램의 구조
```
awk -F,  'NR > 1  { s[$2] += $4 * $5 }  END { for (c in s) print c, s[c] }'
   │      └조건┘   └── 줄마다 실행 ──┘   └──── 마지막에 한 번 실행 ────┘
   └ 구분자
```
- `$1, $2 ...` : 칸, `$0` : 줄 전체, `NR` : 줄 번호, `NF` : 칸 개수
- `s[키] += 값` : **연관 배열**. 키별로 알아서 쌓아 줍니다. "그룹별 합계"는 거의 이 패턴이에요.

## 함정 포인트
- **머리글**: `NR > 1` 이 없으면 `category` 라는 카테고리가 생겨요.
- **정렬 기준**: `sort -nr` 은 줄 맨 앞부터 비교해요. 카테고리가 앞에 있으니 `-k2` 로 2번째 칸을 지정해야 합니다.

## 더 해 보기
```bash
awk -F, 'NR > 1 { s[$1] += $4 * $5 } END { for (d in s) print d, s[d] }' ~/sales.csv | sort   # 날짜별
awk -F, 'NR > 1 && $2 == "음료"' ~/sales.csv | wc -l                                          # 음료 판매 건수
awk -F, 'NR > 1 { t += $4 * $5 } END { printf "%\047d\n", t }' ~/sales.csv                       # 총매출 (천 단위 쉼표)
```
