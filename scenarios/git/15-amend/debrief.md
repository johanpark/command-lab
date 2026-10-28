# 해설

```bash
cd ~/blog
git add login.css
git commit --amend -m "로그인 페이지 추가"
git show --stat HEAD
git push
```

## amend 는 "고치기" 가 아니라 "바꿔치기"
`--amend` 는 마지막 커밋을 고치는 게 아니라, **새 커밋을 만들고 이름표(main)를 그쪽으로 옮겨요.** 해시가 바뀌는 이유예요.
```
전:  A ── B (로긴 페이지 추가)        ← main
후:  A ── B' (로그인 페이지 추가 + css) ← main      (B 는 reflog 에만 남음)
```

## ⚠️ 이미 push 했다면?
원격에는 `B` 가 있는데 내 main 은 `B'` 라서 그냥 push 하면 거절돼요. 이때 `git push --force` 를 하면 **다른 사람이 B 위에 쌓은 작업이 꼬여요.**
- 혼자 쓰는 브랜치라면: `git push --force-with-lease` (원격이 내가 마지막으로 본 상태일 때만 덮어씀)
- 같이 쓰는 main 이라면: amend 하지 말고 **새 커밋으로 고치기**

규칙: **push 전에는 amend·rebase 로 다듬고, push 후에는 새 커밋으로.**

## 자주 쓰는 변형
| 하고 싶은 것 | 명령 |
|---|---|
| 메시지만 고치기 | `git commit --amend -m "..."` |
| 파일만 추가 (메시지 그대로) | `git add 파일 && git commit --amend --no-edit` |
| 작성자 정보 고치기 | `git commit --amend --reset-author --no-edit` |
| 더 이전 커밋 고치기 | `git rebase -i` (지저분한 커밋 정리 시나리오 참고) |
