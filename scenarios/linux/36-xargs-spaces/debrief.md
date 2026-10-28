# 해설

```bash
find ~/reports -name '*.csv' -print0 | xargs -0 cat | wc -l > ~/answer.txt
find ~/reports -name '*.csv' -print0 | xargs -0 gzip
```

## 왜 깨졌을까?
`xargs` 는 입력을 **공백·탭·줄바꿈**으로 잘라서 인자로 만들어요.
```
team a/weekly report.csv   →   "team"  "a/weekly"  "report.csv"
```
`-print0` / `-0` 조합은 구분자를 **NUL(`\0`)** 로 바꿔요. 파일 이름에 절대 들어갈 수 없는 유일한 문자라서 가장 안전해요.

## 같은 일을 하는 다른 방법
| 방법 | 메모 |
|---|---|
| `find ... -exec gzip {} +` | xargs 없이 find 가 직접. 공백 걱정 없음 |
| `find ... -exec gzip {} \;` | 파일 하나마다 한 번씩 실행 (느림) |
| `find ... -delete` | 지우기 전용 |
| `xargs -d '\n'` (GNU) | 줄바꿈으로만 나눔. 이름에 줄바꿈이 없다면 OK |

## wc -l 의 함정
`xargs -0 wc -l` 은 파일별 줄 수와 `total` 을 같이 보여 줘요. 그런데 파일이 아주 많으면 xargs 가 명령을 **여러 번 나눠 실행**해서 `total` 이 여러 개 나올 수 있어요. 합계만 필요하면 `xargs -0 cat | wc -l` 이 확실해요.

## 압축 파일 다시 보기
`zcat 파일.gz`, `zless`, `zgrep` 으로 풀지 않고 볼 수 있어요. 풀려면 `gunzip 파일.gz`.
