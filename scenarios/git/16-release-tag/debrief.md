# 해설

```bash
cd ~/app
git log --oneline -- VERSION              # 1.2.0 커밋 찾기
git tag -a v1.2.0 <해시> -m "1.2.0 릴리스"
git show v1.2.0
git push origin v1.2.0
```

## 태그 두 종류
| | lightweight (`git tag v1`) | annotated (`git tag -a v1 -m ...`) |
|---|---|---|
| 정체 | 커밋을 가리키는 이름표뿐 | 태그 객체 (작성자, 날짜, 메시지) |
| 용도 | 개인 표시 | **릴리스** (`git describe`, GitHub Releases 가 기대) |

## 태그를 쓰는 곳
- `git checkout v1.2.0` → 그 버전 코드 그대로 (장애 재현, 핫픽스 브랜치 시작: `git switch -c hotfix/1.2.1 v1.2.0`)
- `git diff v1.1.0 v1.2.0` / `git log v1.1.0..v1.2.0` → 릴리스 노트 만들기
- `git describe` → `v1.2.0-3-g8d0e7b2` (1.2.0 이후 3커밋)
- CI 가 `v*` 태그 push 를 보고 자동 배포하는 경우도 많아요

## 태그 push 습관
`git push --follow-tags` 를 쓰면 push 하는 커밋에 달린 annotated 태그를 같이 올려요. `git config --global push.followTags true` 로 기본값으로 해 둘 수도 있어요. (`git push --tags` 는 로컬의 **모든** 태그를 올려서 실수로 개인 태그까지 올라갈 수 있어요)
