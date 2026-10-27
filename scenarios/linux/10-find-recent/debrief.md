# 해설

```bash
find ~/app-config -type f -name '*.conf' -mtime -1               # 먼저 눈으로 확인
find ~/app-config -type f -name '*.conf' -mtime -1 > ~/changed.txt
find ~/app-config -type f -empty                                 # 지울 대상 확인
find ~/app-config -type f -empty -delete
```

## 함정 포인트
- `postgres.conf.bak`, `access.log` 도 최근에 수정됐지만 `.conf` 가 아니에요. 조건을 정확히 거는 게 핵심입니다.
- `-type f` 없이 `-empty -delete` 를 하면 **빈 폴더(empty-dir)까지 지워집니다.**
- `-name *.conf` 처럼 따옴표를 빼면, 현재 폴더에 `.conf` 파일이 있을 때 셸이 먼저 펼쳐 버려서 엉뚱하게 동작해요. 항상 `'*.conf'`.

## 시간 조건 정리
| 조건 | 뜻 |
|---|---|
| `-mtime -1` | 24시간 이내 수정 |
| `-mtime +30` | 30일보다 오래전 수정 |
| `-mmin -30` | 30분 이내 수정 |
| `-newer 파일` | 그 파일보다 나중에 수정 |

## 찾은 것으로 무언가 하기
```bash
find . -name '*.conf' -mtime -1 -exec ls -l {} \;     # 하나씩 명령 실행
find . -name '*.log' -mtime +30 | xargs rm             # 목록을 다른 명령에 넘기기
find . -name '*.conf' -mtime -1 | xargs grep timeout   # 바뀐 파일에서 문자열 찾기
```
