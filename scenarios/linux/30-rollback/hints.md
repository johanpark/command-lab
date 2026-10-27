`ls -l ~/app` 과 `curl -i http://localhost:8080/health` 로 상황부터 보세요. 404 가 나오죠?
---
`cd ~/app && ln -sfn releases/2.3.1 current` 로 링크를 바꾸세요. ⚠️ `-n` 을 빼면 `current` 가 이미 폴더를 가리키는 링크라서, **그 폴더 안에** `2.3.1` 이라는 링크가 새로 생겨 버려요 (2.4.0 폴더가 오염됨).
---
`readlink ~/app/current` 로 확인하고 `~/app/restart.sh`. 서버는 시작할 때 경로를 잡기 때문에 재시작해야 바뀐 링크를 따라가요.
---
원인 분석: `diff -r ~/app/releases/2.3.1 ~/app/releases/2.4.0` 에서 `Only in .../2.3.1: 파일` 이 빠진 파일이에요. `echo 파일이름 > ~/answer.txt`
