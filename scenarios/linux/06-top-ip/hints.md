한 번에 다 하려고 하지 말고 단계별로! 먼저 `awk '{print $1}' ~/access.log | head` 로 IP만 뽑히는지 확인하세요.
---
같은 IP끼리 세려면 먼저 모아야(정렬) 해요: `awk '{print $1}' ~/access.log | sort | uniq -c | head`
---
이제 개수로 정렬: `... | sort | uniq -c | sort -rn | head -n 5`. 이 결과를 `> ~/top5.txt` 로 저장하세요.
---
1등 IP만 뽑으려면: `... | sort -rn | head -n 1 | awk '{print $2}' > ~/answer.txt`
