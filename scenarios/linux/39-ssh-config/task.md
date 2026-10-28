# ssh 접속 별칭 만들기 (~/.ssh/config)

서버에 접속할 때마다 이렇게 길게 치고 있어요.

```
ssh -i ~/.ssh/web_key -p 2222 deploy@10.20.3.14
```

`~/.ssh/config` 에 별칭을 만들어 두면 `ssh web` 만 쳐도 돼요. 접속할 서버 정보는 `~/servers.txt` 에 있어요. `~/.ssh/config` 에는 회사 공통 설정이 **이미 들어 있으니** 지우지 말고 함께 써야 해요.

## 목표
1. `ssh web`, `ssh db` 가 `~/servers.txt` 의 **주소, 사용자, 포트, 키 파일**로 접속하도록 설정하세요.
2. 기존 설정(`bastion` 별칭, 모든 서버 공통 `ServerAliveInterval`)은 **계속 동작**해야 해요.
3. 설정 파일은 **다른 사람이 쓸 수 없는 권한**이어야 해요. (그렇지 않으면 ssh 가 설정 파일을 거부해요)

> 이 실습 환경에는 실제 서버가 없어서 접속은 안 돼요. 대신 **`ssh -G 별칭`** 으로 ssh 가 실제로 쓸 설정을 확인할 수 있어요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `cat ~/.ssh/config` | 지금 설정 보기 |
| `nano ~/.ssh/config` | 편집 |
| `ssh -G web` | `web` 에 접속할 때 쓰일 **최종 설정** 전부 출력 |
| `ssh -G web \| grep -E '^(hostname\|user\|port\|identityfile) '` | 필요한 줄만 |
| `chmod 600 ~/.ssh/config` | 나만 읽고 쓰기 |

설정 예:
```
Host 별칭
    HostName 주소
    User 사용자
    Port 포트
    IdentityFile ~/.ssh/키파일
```
