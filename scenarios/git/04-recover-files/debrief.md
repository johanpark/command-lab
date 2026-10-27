# 해설

```bash
cd ~/recipes
git status                               # modified: kimchi.md, deleted: bulgogi.md
git diff kimchi.md                       # 정말 버려도 되는지 확인
git restore kimchi.md bulgogi.md

git log --oneline --diff-filter=D --name-only
# a1b2c3d 안 쓰는 레시피 정리
# bibimbap.md
git show a1b2c3d^:bibimbap.md            # 지우기 직전 내용 미리 보기
git restore --source=a1b2c3d^ bibimbap.md
git add bibimbap.md
git commit -m "비빔밥 레시피 복구"
```

## 함정 포인트
첫 커밋(`레시피 세 개 추가`)에서 꺼내면 나중에 추가한 **비법 줄이 빠진** 옛 버전이 나옵니다. "지워지기 **직전**" = 지운 커밋의 **부모(`^`)** 예요.

## 되돌리기 명령 정리
| 상황 | 명령 |
|---|---|
| 작업 중인 변경 버리기 | `git restore 파일` |
| `git add` 한 것 빼기 | `git restore --staged 파일` |
| 예전 버전 파일 꺼내기 | `git restore --source=커밋 파일` |
| 마지막 커밋 메시지/내용 고치기 | `git commit --amend` |
| 이미 공유한 커밋 되돌리기 | `git revert 커밋` (기록을 지우지 않고 반대 커밋 추가) |

> 예전 문서에서는 `git checkout -- 파일` 을 많이 볼 거예요. 같은 일을 하지만 `checkout` 이 하는 일이 너무 많아서, 요즘은 `restore`(파일)와 `switch`(브랜치)로 나눠 씁니다.
