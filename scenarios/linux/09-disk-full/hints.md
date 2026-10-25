위에서부터 좁혀 가세요. `du -sh ~/app/*` 로 어느 폴더가 큰지 먼저 봅니다.
---
가장 큰 폴더 안으로 들어가서 다시 `du -sh *` 또는 `ls -lhS`. 숨김 폴더(`.`으로 시작)도 있을 수 있어요: `du -sh .[!.]* *`
---
한 번에 찾기: `find ~/app -type f -size +10M -exec ls -lh {} \;` 또는 `du -ah ~/app | sort -h | tail -n 5`
---
경로를 확인했으면 `echo 경로 > ~/answer.txt`, 그다음 `rm 경로`. 지우기 전에 `ls -lh 경로` 로 한 번 더 확인!
