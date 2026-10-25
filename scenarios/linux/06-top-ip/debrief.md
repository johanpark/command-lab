# 해설

```bash
awk '{print $1}' ~/access.log | sort | uniq -c | sort -rn | head -n 5 > ~/top5.txt
head -n 1 ~/top5.txt | awk '{print $2}' > ~/answer.txt
```

## 파이프라인 한 단계씩
| 단계 | 결과 |
|---|---|
| `awk '{print $1}'` | IP만 한 줄에 하나씩 |
| `sort` | 같은 IP끼리 붙어 있게 정렬 |
| `uniq -c` | `  812 198.51.100.4` 처럼 개수 붙여 합치기 |
| `sort -rn` | 개수 많은 순으로 |
| `head -n 5` | 상위 5개 |

이 **`sort | uniq -c | sort -rn | head`** 조합은 "무엇이 가장 많은가?"를 묻는 거의 모든 상황(가장 많이 호출된 URL, 가장 흔한 에러 메시지, 가장 많이 쓴 명령어 등)에 그대로 쓰여요. 꼭 손에 익혀 두세요.

## 응용
```bash
awk '$9 == 401 {print $1}' ~/access.log | sort | uniq -c | sort -rn | head   # 401 응답만
awk '{print $7}' ~/access.log | sort | uniq -c | sort -rn | head             # 많이 요청된 경로
history | awk '{print $2}' | sort | uniq -c | sort -rn | head                 # 내가 많이 쓴 명령어
```
