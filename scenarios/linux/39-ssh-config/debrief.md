# 해설

완성된 `~/.ssh/config` 예:
```
Host web
    HostName 10.20.3.14
    User deploy
    Port 2222
    IdentityFile ~/.ssh/web_key

Host db
    HostName 10.20.5.7
    User dbadmin
    IdentityFile ~/.ssh/db_key

Host bastion
    HostName 10.0.0.5

# 회사 공통 설정 — 맨 아래에!
Host *
    User admin
    ServerAliveInterval 60
```

## 먼저 나온 값이 이긴다
ssh 는 설정 파일을 위에서 아래로 읽으면서, 접속 대상과 맞는 `Host` 블록의 값을 모아요. **같은 항목은 처음 정해진 값이 최종**이에요. (나중에 나온 값이 덮어쓰는 보통의 설정 파일과 반대!)
그래서 규칙은 하나: **구체적인 Host 는 위, `Host *` 는 맨 아래.**

예외로 `IdentityFile` 은 여러 개가 쌓여서 순서대로 시도돼요.

## ssh -G 로 확인하는 습관
`ssh -G 별칭` 은 접속하지 않고 **최종 설정**만 보여 줘요. "왜 이 사용자로 붙지?" 할 때 가장 먼저 쳐 볼 명령이에요. 접속 과정을 자세히 보려면 `ssh -v 별칭`.

## 별칭이 생기면 좋은 점
`scp 파일 web:/tmp/`, `rsync -a 폴더/ web:backup/`, `git clone web:repo.git` 처럼 ssh 를 쓰는 모든 도구가 같은 별칭을 써요. 점프 서버를 거쳐야 하면 `ProxyJump bastion` 한 줄로 해결돼요.
