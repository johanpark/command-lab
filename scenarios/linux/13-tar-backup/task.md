# 백업에서 파일 하나만 살리기

동료가 실수로 `~/project/src/config.js` 를 지워 버렸습니다. 다행히 지난주 백업 `~/backups/project-2026-10-20.tar.gz` 가 있어요. 하지만 백업 이후에 다른 파일들은 많이 수정됐습니다.

## 목표
1. 백업에서 **`config.js` 하나만** 꺼내서 원래 자리(`~/project/src/config.js`)에 복구하세요.
   **다른 파일을 백업 시점으로 덮어쓰면 안 됩니다!** (그동안의 작업이 날아가요)
2. 복구가 끝난 지금의 `~/project` 를 `~/backups/project-today.tar.gz` 로 새로 백업하세요.
   단, 용량만 큰 **`node_modules` 폴더는 제외**하세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `tar -tzf 파일.tar.gz` | 아카이브 안의 목록 보기 (풀지 않음) |
| `tar -xzf 파일.tar.gz` | 전부 풀기 (⚠️ 같은 이름 파일 덮어씀) |
| `tar -xzf 파일.tar.gz 경로` | 특정 파일만 풀기 |
| `tar -xzf ... -C 폴더` | 지정한 폴더에 풀기 |
| `tar -czf 새파일.tar.gz 대상` | 압축해서 묶기 |
| `--exclude=패턴` | 묶을 때 제외 |

> 💡 옵션 외우는 법: **c**reate / e**x**tract / lis**t**, **z** = gzip, **f** = 파일 이름, **v** = 진행 상황 출력
