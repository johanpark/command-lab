# 이름에 공백이 있는 파일 한꺼번에 처리하기

`~/reports` 에 팀마다 올린 CSV 리포트가 하위 폴더 곳곳에 흩어져 있어요. 디스크를 아끼려고 전부 압축하려는데, 동료가 이렇게 했더니 에러가 잔뜩 났대요.

```
$ find ~/reports -name '*.csv' | xargs gzip
gzip: /home/learner/reports/team: No such file or directory
gzip: a/weekly: No such file or directory
...
```

## 목표
1. `~/reports` 아래(하위 폴더 포함) **모든 `.csv` 파일의 줄 수 합계**를 `~/answer.txt` 에 숫자 하나로 저장하세요.
2. 모든 `.csv` 파일을 **그 자리에서 gzip 으로 압축**하세요. (`a.csv` → `a.csv.gz`)
3. `.csv` 가 아닌 파일은 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `find 폴더 -name '*.csv'` | 조건에 맞는 파일 찾기 |
| `명령1 \| xargs 명령2` | 명령1 의 출력을 명령2 의 **인자**로 넘기기 |
| `find ... -print0 \| xargs -0 ...` | 파일 이름을 공백 대신 NUL 문자로 구분해서 넘기기 |
| `find ... -exec 명령 {} +` | xargs 없이 find 가 직접 실행 |
| `wc -l 파일...` | 줄 수 (파일이 여러 개면 마지막에 `total`) |
| `gzip 파일...` | 압축 (원본은 `.gz` 로 바뀜) |
