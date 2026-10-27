`cd ~/pricing && ./test.sh; echo $?` 로 지금 실패(1)하는지 보고, 첫 커밋은 `git log --oneline | tail -1` 로 찾으세요.
---
`git bisect start` → `git bisect bad` (지금 HEAD) → `git bisect good <첫 커밋 해시>`. Git 이 가운데 커밋으로 이동해요.
---
손으로: 이동할 때마다 `./test.sh` 를 돌리고 결과에 따라 `git bisect good` 또는 `git bisect bad`. 자동으로: `git bisect run ./test.sh` (종료 코드 0 = good, 그 외 = bad)
---
`... is the first bad commit` 이 나오면 그 해시를 `~/answer.txt` 에 저장하고, **꼭** `git bisect reset` 으로 돌아오세요!
