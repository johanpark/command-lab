`git log --oneline -- VERSION` 으로 VERSION 을 바꾼 커밋들을 보고, `git show 해시:VERSION` 으로 그때 값이 `1.2.0` 인지 확인하세요. 기존 `v1.1.0` 태그가 어떻게 달려 있는지 `git show v1.1.0` 으로 보면 참고가 돼요.
---
태그는 커밋을 지정하지 않으면 **지금 HEAD** 에 달려요. 1.2.0 커밋 해시를 꼭 넣으세요: `git tag -a v1.2.0 <해시> -m "1.2.0 릴리스"`
---
`git push` 는 브랜치만 올리고 **태그는 안 올려요.** `git push origin v1.2.0`. 확인: `git ls-remote --tags origin`
---
잘못 달았다면: `git tag -d v1.2.0` 로 지우고 다시. 이미 원격에 올렸다면 `git push origin --delete v1.2.0` 후 다시 올리기.
