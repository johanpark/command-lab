# 특정 명령만 sudo 허용하기

배포 자동화 계정 **`deploy`** 가 배포 마지막에 앱을 재시작해야 해요. 재시작 스크립트 `/usr/local/bin/app-restart` 는 root 권한이 필요합니다.

"그냥 deploy 에게 sudo 전체 권한 주면 되잖아?" → 안 돼요. deploy 계정이 털리면 서버 전체가 털려요. **필요한 명령 하나만** 허용합시다.

## 목표
1. `deploy` 가 **`/usr/local/bin/app-restart` 만** `sudo` 로, **비밀번호 없이** 실행할 수 있게 하세요.
2. 다른 명령(예: `sudo cat /etc/shadow`)은 `deploy` 가 sudo 로 실행할 수 **없어야** 해요.
3. 설정은 `/etc/sudoers.d/deploy` 파일에, 권한은 **`0440`** 으로.
4. ⚠️ sudoers 파일에 문법 오류가 있으면 **sudo 가 통째로 고장나요** (나도 sudo 를 못 쓰게 됨). 반드시 **`visudo` 로 검사**하세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `sudo visudo -f /etc/sudoers.d/deploy` | 문법 검사를 해 주는 편집기로 열기 |
| `sudo visudo -c` | 모든 sudoers 파일 문법 검사 |
| `sudo -l -U deploy` | deploy 가 sudo 로 할 수 있는 것 목록 |
| `sudo -u deploy sudo -n /usr/local/bin/app-restart` | deploy 로서 시험해 보기 (`-n` = 비밀번호 묻지 말고 실패) |

## sudoers 한 줄의 모양
```
누가   어느호스트=(누구로서)  옵션:      명령
deploy ALL=(root)          NOPASSWD: /usr/local/bin/app-restart
```
