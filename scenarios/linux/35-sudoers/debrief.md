# 해설

```bash
sudo visudo -f /etc/sudoers.d/deploy
#   deploy ALL=(root) NOPASSWD: /usr/local/bin/app-restart
sudo chmod 440 /etc/sudoers.d/deploy
sudo visudo -c
sudo -l -U deploy
#   (root) NOPASSWD: /usr/local/bin/app-restart
```

## 왜 visudo 인가
sudoers 에 오타 하나만 있어도 sudo 는 **아예 동작을 거부**해요. 그러면 root 비밀번호가 없는 서버에서는 고칠 방법도 없어요. `visudo` 는 저장 전에 문법을 검사해서 이 사고를 막아 줍니다. 파일을 다른 방법으로 만들었다면 적어도 `visudo -cf 파일` 로 검사하세요.

## 최소 권한의 원칙
| 설정 | 위험도 |
|---|---|
| `deploy ALL=(ALL) NOPASSWD: ALL` | deploy 가 털리면 서버 전체가 털림 ❌ |
| `deploy ALL=(root) NOPASSWD: /usr/bin/systemctl` | `systemctl` 로 아무 서비스나 조작 가능 ⚠️ |
| `deploy ALL=(root) NOPASSWD: /usr/local/bin/app-restart` | 딱 이것만 ✅ |

## 주의할 점
- 명령은 **전체 경로**로 써야 해요.
- 허용한 스크립트를 deploy 가 **수정할 수 있으면** 소용없어요. 스크립트는 root 소유, `755` 로.
- `vim`, `less`, `find` 처럼 **다른 명령을 실행할 수 있는 프로그램**을 허용하면 그 안에서 root 셸을 얻을 수 있어요 (`:!bash`).
