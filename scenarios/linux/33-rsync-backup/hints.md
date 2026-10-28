먼저 차이를 보세요: `diff -r ~/photos /mnt/backup/photos`. "Only in" 이 추가·삭제된 것, "differ" 가 바뀐 거예요.
---
rsync 의 **끝 슬래시**: `rsync -a ~/photos /mnt/backup/photos/` 는 `/mnt/backup/photos/photos/` 를 만들어요. 원본 끝에 `/` 를 붙여야 "내용만" 복사해요: `rsync -a ~/photos/ /mnt/backup/photos/`
---
`--delete` 는 강력해서 경로를 틀리면 백업을 날려요. 꼭 `-n` 으로 먼저: `rsync -avn --delete ~/photos/ /mnt/backup/photos/` → 목록의 `deleting ...` 이 예상대로인지 확인
---
확인이 끝났으면 `-n` 을 빼고 실행 → `diff -r ~/photos /mnt/backup/photos` 가 아무것도 출력하지 않으면 성공!
