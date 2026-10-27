# 해설

```bash
ssh-keygen -t ed25519 -C "learner@lab"           # Enter, Enter, Enter
ls -l ~/.ssh                                     # id_ed25519 (600), id_ed25519.pub (644)
sudo mkdir -p /home/deploy/.ssh
cat ~/.ssh/id_ed25519.pub | sudo tee -a /home/deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
```

## 실제 원격 서버라면
```bash
ssh-copy-id deploy@서버주소       # 위의 등록 과정을 한 번에 (권한까지 맞춰 줌)
ssh deploy@서버주소               # 이제 비밀번호 없이 접속
```
Windows 도 PowerShell 에서 `ssh-keygen`, `ssh` 를 그대로 쓸 수 있어요. 키는 `C:\Users\이름\.ssh\` 에 생깁니다.

## 함정 포인트
- **`sudo cat 키 >> 파일` 은 실패**합니다. `>>` 는 sudo 가 아니라 **지금 내 셸**(권한 없음)이 처리해요. 그래서 `sudo tee -a` 를 씁니다.
- sudo 로 만든 폴더/파일은 **root 소유**예요. SSH 는 남의(root) 파일이나 느슨한 권한(`755`, `644`)의 authorized_keys 를 보안상 무시합니다. 접속이 안 될 때 가장 흔한 원인이에요.
- 접속 문제를 볼 때는 `ssh -v deploy@서버` 로 자세한 과정을 출력해 보세요.

## 키 파일 정리
| 파일 | 어디에 | 권한 |
|---|---|---|
| `id_ed25519` (개인키) | **내 컴퓨터에만** | 600 |
| `id_ed25519.pub` (공개키) | 서버의 authorized_keys 에 붙여 넣기 | 644 |
| `authorized_keys` | 서버의 `~/.ssh/` | 600 |
| `known_hosts` | 내 컴퓨터. 접속했던 서버의 지문 | 644 |
