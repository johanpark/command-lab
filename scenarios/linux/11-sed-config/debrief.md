# 해설

```bash
grep -rn old-db ~/services                       # 어디에 있는지 확인
grep -rl --include=config.ini old-db ~/services \
  | xargs sed -i 's/old-db\.internal/new-db.internal/g'
grep -rnE 'debug *= *true' ~/services            # 띄어쓰기가 제각각
grep -rlE --include=config.ini '^debug *= *true' ~/services \
  | xargs sed -i 's/^debug *= *true$/debug = false/'
grep -rn 'old-db\|debug' ~/services              # 결과 확인
```

## 함정 포인트
- **`g` 플래그**: `replica = old-db.internal:5433, old-db.internal:5434` 처럼 한 줄에 두 번 나오면, `g` 없이는 첫 번째만 바뀝니다.
- **깊은 폴더**: `~/services/*/config.ini` 는 `legacy/batch/conf/config.ini` 를 놓쳐요. `grep -rl ... | xargs` 나 `find ... -exec` 가 안전합니다.
- **너무 넓은 패턴**: `s/true/false/` 로 바꾸면 `debug_sql = true` 까지 바뀝니다. `^debug *= *true$` 처럼 **줄 시작(^)과 끝($)** 을 고정하세요.
- 정규식에서 `.` 은 "아무 글자"라서 `old-db.internal` 은 `old-dbXinternal` 에도 맞아요. 정확히 하려면 `old-db\.internal`.

## sed 더 알아보기
```bash
sed -i.bak 's/a/b/g' f.txt     # 원본을 f.txt.bak 으로 남기고 수정
sed -n '/\[database\]/,/^$/p' f # [database] 부터 빈 줄까지만 출력
sed '/^#/d' f                   # 주석 줄 지우기
```
