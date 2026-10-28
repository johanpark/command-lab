# .gitignore 에 넣었는데 계속 올라가요

블로그 저장소 `~/blog` 에 실수로 `.env`, 로그 파일, `node_modules/` 까지 커밋해 버렸어요. 그래서 `.gitignore` 를 만들어 커밋했는데...

```
$ git status
Changes not staged for commit:
        modified:   logs/app.log
```

`.gitignore` 에 `logs/` 를 분명히 적었는데, 로그가 바뀔 때마다 여전히 변경 사항으로 잡혀요.

## 목표
1. `.gitignore` 에 적힌 파일들(`.env`, `logs/`, `node_modules/`, `.DS_Store`)을 **저장소에서 빼고** 커밋하세요.
2. 단, 내 컴퓨터의 **실제 파일은 지우면 안 돼요.** (앱이 써야 하니까요)
3. 블로그 글(`index.md`, `posts/`)과 `.gitignore` 는 계속 저장소에 있어야 해요.
4. 끝나면 `git status` 가 깨끗해야 해요. (기존 커밋 기록은 그대로 두세요)

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `git ls-files` | Git 이 **추적 중인** 파일 목록 |
| `cat .gitignore` | 무시 규칙 |
| `git check-ignore -v 파일` | 그 파일이 어떤 규칙으로 무시되는지 |
| `git rm --cached 파일` | 저장소에서만 빼기 (실제 파일은 남김) |
| `git rm -r --cached 폴더` | 폴더째 빼기 |
| `git commit -m "메시지"` | 커밋 |
