# 해설

```bash
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' ~/request.txt | sudo tee -a /etc/app/allowed_ips > /dev/null
printf 'MAINTENANCE=on\nUNTIL=06:00\n' | sudo tee /etc/app/maintenance.conf > /dev/null
```

## 왜 sudo 가 안 먹혔을까?
```
sudo echo x  >>  /etc/app/allowed_ips
└─ root ──┘   └── 내 셸(learner) 이 파일을 연다 ──┘
```
리다이렉션(`>`, `>>`, `<`)은 명령이 실행되기 **전에** 셸이 처리해요. sudo 는 그 뒤에 실행되는 명령에만 붙어요.

## 해결 방법 3가지
| 방법 | 메모 |
|---|---|
| `... \| sudo tee -a 파일` | 가장 흔함. **`-a` 빼먹으면 파일 전체가 날아감** |
| `sudo sh -c 'echo x >> 파일'` | 따옴표 안 전체가 root 셸에서 실행 |
| `sudo nano 파일` / `sudoedit 파일` | 손으로 편집 |

## tee 덮어쓰기 사고
`echo x | sudo tee /etc/hosts` 처럼 `-a` 를 빼먹으면 **기존 내용이 한 줄로 바뀌어요.** 중요한 설정 파일을 고치기 전에는 `sudo cp 파일 파일.bak` 으로 백업해 두는 습관을 들이세요.

## 소유자도 중요해요
홈에서 파일을 만들어 `sudo mv` 로 옮기면 소유자가 learner 그대로라서, learner 가 나중에 마음대로 고칠 수 있어요. `/etc` 의 설정 파일은 root 소유가 원칙이에요. (`sudo cp` 또는 `sudo install -o root -g root -m 644` 를 쓰세요.)
