`ls -l ~/deploy.sh ~/secrets` 로 지금 권한을 확인하세요. `rw-` 는 읽기(r)·쓰기(w)는 되고 실행(x)은 안 된다는 뜻이에요.
---
권한 10글자 읽는 법: `-` `rwx` `r-x` `r--` → 종류 / **소유자** / **그룹** / **그 외 모든 사람**
---
실행 권한 추가는 `chmod +x ~/deploy.sh`, 그다음 `cd ~ && ./deploy.sh`
---
숫자 권한: r=4, w=2, x=1 을 더해요. 나만 읽기+쓰기 = 6, 나머지 0 → `chmod 600 ~/secrets/api.key`. 폴더는 들어가려면 x가 필요하니 나만 rwx = 7 → `chmod 700 ~/secrets`
