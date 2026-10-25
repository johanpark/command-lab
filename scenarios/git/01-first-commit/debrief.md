# 해설

```bash
cd ~/my-notes
git init
git status                      # 세 파일 모두 Untracked
git add notes.md todo.md
git status                      # 두 파일이 "Changes to be committed"
git commit -m "공부 노트 시작"
git log --oneline
```

## Git의 세 공간
```
작업 폴더  ──git add──▶  스테이징 영역  ──git commit──▶  저장소(커밋 기록)
(파일 수정)              (다음 커밋에 담을 것)          (영구 기록)
```
`git add` 는 "이번 커밋에 이걸 넣겠다"고 **고르는** 단계예요. 그래서 원하는 파일만 골라서 커밋할 수 있습니다.

## 더 나아가기
임시 파일을 매번 피하는 건 번거로우니 `.gitignore` 에 적어 두세요.
```bash
echo "*.tmp" > .gitignore
git add .gitignore && git commit -m "임시 파일 무시"
```
이제 `git status` 에서 scratch.tmp 가 보이지 않습니다.
