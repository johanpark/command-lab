먼저 `find ~/reports -name '*.csv'` 로 목록을 보세요. `team a`, `weekly report.csv` 처럼 **공백이 들어간 이름**이 있죠?
---
`xargs` 는 기본으로 **공백과 줄바꿈**을 기준으로 인자를 나눠요. 그래서 `team a/weekly report.csv` 가 `team`, `a/weekly`, `report.csv` 세 개로 쪼개져요.
---
`find` 는 `-print0` 으로 이름 사이에 NUL 문자를 넣을 수 있고, `xargs -0` 은 NUL 로만 나눠요. 둘은 짝꿍이에요: `find ~/reports -name '*.csv' -print0 | xargs -0 wc -l`
---
줄 수 합계: `find ~/reports -name '*.csv' -print0 | xargs -0 cat | wc -l > ~/answer.txt`
압축: `find ~/reports -name '*.csv' -print0 | xargs -0 gzip`
