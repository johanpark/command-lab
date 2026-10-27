# 해설

```bash
tar -tzf ~/backups/project-2026-10-20.tar.gz | head        # 경로 확인: project/src/...
tar -xzf ~/backups/project-2026-10-20.tar.gz -C ~ project/src/config.js
cat ~/project/src/config.js

tar -czf ~/backups/project-today.tar.gz --exclude=node_modules -C ~ project
tar -tzf ~/backups/project-today.tar.gz | grep -c node_modules   # 0
ls -lh ~/backups                                                  # 크기 비교
```

## 함정 포인트
- `cd ~ && tar -xzf 백업.tar.gz` 로 **전부 풀면** `app.js`, `guide.md` 가 지난주 버전으로 **조용히 덮어써집니다.** 복원은 항상 "목록 확인 → 필요한 것만" 순서로.
- 아카이브 안의 경로를 정확히 써야 해요. `tar -tzf` 결과를 그대로 복사하세요.
- `-C 폴더` 는 "이 폴더로 가서 작업해라"는 뜻이에요. 묶을 때 `-C ~ project` 로 하면 아카이브 안 경로가 `/home/learner/...` 가 아니라 `project/...` 로 깔끔해집니다.

## 압축 형식 정리
| 확장자 | 묶기 | 풀기 |
|---|---|---|
| `.tar.gz` / `.tgz` | `tar -czf` | `tar -xzf` |
| `.tar.bz2` | `tar -cjf` | `tar -xjf` |
| `.tar.xz` | `tar -cJf` | `tar -xJf` |
| `.zip` | `zip -r a.zip 폴더` | `unzip a.zip` |
| `.gz` (파일 하나) | `gzip 파일` | `gunzip 파일.gz` |

요즘 tar 는 풀 때 압축 형식을 알아서 판단하므로 `tar -xf 파일` 만으로도 됩니다.
