# 방금 한 커밋 고치기 (amend)

로그인 페이지를 만들고 커밋했는데, 커밋하고 나서야 두 가지가 보였어요.

```
$ git log --oneline -1
3f2a1c9 로긴 페이지 추가          ← 오타!
$ git status
Untracked files:
        login.css                 ← 같이 커밋했어야 하는 파일
```

다행히 **아직 push 하지 않았어요.** "오타 수정", "css 빠뜨림" 같은 커밋을 덧붙이면 기록이 지저분해지니, **방금 커밋 자체를 고쳐서** 올리고 싶어요.

## 목표 (`~/blog` 저장소)
1. 마지막 커밋의 메시지를 **`로그인 페이지 추가`** 로 고치세요.
2. `login.css` 를 **그 커밋에 포함**하세요. (새 커밋을 하나 더 만들면 안 돼요)
3. 고친 커밋을 원격(`origin`)의 `main` 에 **push** 하세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `git show --stat HEAD` | 마지막 커밋에 든 파일 |
| `git add 파일` | 다음 커밋에 넣을 파일 고르기 |
| `git commit --amend -m "새 메시지"` | **방금 커밋을 고쳐 다시 만들기** (스테이징한 파일도 합쳐짐) |
| `git commit --amend --no-edit` | 메시지는 그대로, 파일만 추가 |
| `git log --oneline origin/main..main` | 아직 push 안 한 커밋 |
| `git push` | 올리기 |
