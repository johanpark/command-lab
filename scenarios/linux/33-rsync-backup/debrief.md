# 해설

```bash
diff -r ~/photos /mnt/backup/photos                    # 차이 확인
rsync -avn --delete ~/photos/ /mnt/backup/photos/      # 미리보기
rsync -av  --delete ~/photos/ /mnt/backup/photos/      # 실행
diff -r ~/photos /mnt/backup/photos                    # 출력 없음 = 같음
```

## 끝 슬래시 한 글자의 차이
| 명령 | 결과 |
|---|---|
| `rsync -a ~/photos/ /mnt/backup/photos/` | `/mnt/backup/photos/2026-09/...` ✅ |
| `rsync -a ~/photos /mnt/backup/photos/` | `/mnt/backup/photos/photos/2026-09/...` ❌ |
| `rsync -a ~/photos /mnt/backup/` | `/mnt/backup/photos/...` ✅ (폴더째 복사) |
**원본** 끝의 `/` 가 "폴더 안의 내용"이라는 뜻이에요. 대상 끝의 `/` 는 결과에 영향이 없어요.

## --delete 를 쓸 때
- 원본 경로를 잘못 쓰면(빈 폴더, 오타) 백업이 **통째로 지워질 수 있어요.** 항상 `-n` 먼저.
- "백업에서는 지우지 말고 쌓기만" 하고 싶다면 `--delete` 없이 쓰세요.

## cp 대신 rsync 인 이유
- **바뀐 파일만** 보내서 빨라요 (두 번째부터는 거의 즉시)
- 원격 서버로도 같은 문법: `rsync -a ~/photos/ user@backup-server:/backup/photos/`
- 중간에 끊겨도 다시 실행하면 이어서 맞춰요
