`grep -rn old-db ~/services` 로 어디에 몇 번 나오는지 먼저 확인하세요. `debug` 도 같은 방법으로.
---
`sed 's/old-db.internal/new-db.internal/g' ~/services/billing/config.ini` 로 결과를 미리 봅니다. 끝의 `g` 가 없으면 **한 줄에서 첫 번째만** 바뀌어요.
---
파일 여러 개를 한 번에: `sed -i 's/old-db.internal/new-db.internal/g' ~/services/*/config.ini`. 하위 폴더 깊이가 제각각이면 `grep -rl old-db ~/services | xargs sed -i '...'`
---
`debug = true` 는 띄어쓰기가 파일마다 다를 수 있어요(`debug=true`, `debug  =  true`). `grep -rn debug ~/services` 로 확인하고, 정규식 `debug *= *true` 를 써 보세요: `sed -i 's/debug *= *true/debug = false/'`
