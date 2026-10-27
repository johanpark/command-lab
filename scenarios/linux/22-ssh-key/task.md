# SSH 키로 접속 준비하기

배포용 계정 **`deploy`** 에 비밀번호 대신 **SSH 키**로 접속하려고 합니다. (이 실습에서는 같은 서버 안의 계정을 쓰지만, 실제 원격 서버도 똑같아요.)

## 목표
1. 내 계정(learner)에 **ed25519** 방식의 SSH 키를 만드세요.
   - 위치: `~/.ssh/id_ed25519` (기본값), 암호(passphrase)는 비워도 돼요
   - 코멘트: `learner@lab`
2. 내 **공개키**를 `deploy` 계정의 `~/.ssh/authorized_keys` (`/home/deploy/.ssh/authorized_keys`) 에 등록하세요.
3. SSH 는 권한이 느슨하면 키를 **무시**합니다. deploy 계정 쪽을 이렇게 맞추세요:
   - `/home/deploy/.ssh` → 소유자 `deploy`, 권한 `700`
   - `/home/deploy/.ssh/authorized_keys` → 소유자 `deploy`, 권한 `600`

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `ssh-keygen -t ed25519 -C "코멘트"` | 키 쌍 만들기 (개인키 + `.pub` 공개키) |
| `cat ~/.ssh/id_ed25519.pub` | 공개키 내용 |
| `sudo mkdir`, `sudo tee -a 파일` | 다른 계정의 폴더/파일 다루기 |
| `sudo chown -R 사용자:그룹 경로` | 소유자 바꾸기 |
| `ssh-keygen -l -f 키파일` | 키 지문(fingerprint) 확인 |

> ⚠️ **개인키(`id_ed25519`)는 절대 다른 곳에 복사하지 마세요.** 서버에 올리는 건 항상 `.pub` 이에요.
