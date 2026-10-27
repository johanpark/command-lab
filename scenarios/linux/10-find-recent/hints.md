먼저 `find ~/app-config -name '*.conf'` 로 설정 파일이 몇 개인지 보세요. 너무 많죠? 여기에 조건을 하나씩 붙여 갑니다.
---
`-mtime -1` 을 붙이면 최근 24시간 안에 바뀐 것만 남아요. `.conf` 가 아닌 파일(백업, 로그)도 최근에 바뀌었을 수 있으니 `-name` 조건은 꼭 같이 쓰세요.
---
결과를 그대로 저장: `find ~/app-config -type f -name '*.conf' -mtime -1 > ~/changed.txt`
---
빈 파일: 먼저 `find ~/app-config -type f -empty` 로 확인하고, 맞으면 끝에 `-delete` 를 붙이세요. `-type f` 를 빼면 빈 폴더까지 지워져요!
