# 해설

```bash
ss -ltn                         # 8080, 9100 이 열려 있음
sudo ss -ltnp | grep 8080       # users:(("legacy-api",pid=42,fd=3))
echo legacy-api > ~/answer.txt
sudo kill 42
ss -ltn | grep 8080             # 비었는지 확인
~/myapp/start.sh
ss -ltnp | grep 8080            # 이제 myapp
```

## 기억할 것
- **"Address already in use"** 를 보면 바로 `sudo ss -ltnp` (또는 `sudo lsof +c 0 -i :포트`, `sudo netstat -ltnp`).
- 다른 사용자(root)의 프로세스는 일반 권한으로는 이름이 안 보이고(`ss -ltnp` 의 프로세스 칸이 빈칸) 종료도 안 돼요(`Operation not permitted`). 그래서 `sudo` 가 필요합니다.
- `lsof` 는 이름을 9글자, `top` 은 칸 너비만큼 잘라 보여 줘요(`old-gatew`, `old-gat+`). 정확한 이름은 `ss -p`, `ps -o comm`, 또는 `lsof +c 0`.
- 종료 직후엔 포트가 아주 잠깐 남아 있을 수 있어요. 다시 확인하고 시작하세요.

## 백그라운드 실행 정리
| 방법 | 특징 |
|---|---|
| `명령 &` | 백그라운드 실행. 터미널을 닫으면 같이 죽을 수 있음 |
| `nohup 명령 &` | 터미널을 닫아도 살아 있음 (출력은 nohup.out) |
| `jobs`, `fg`, `bg` | 현재 셸의 백그라운드 작업 관리 |
| `systemctl start 서비스` | 실제 서버에서는 보통 이렇게 서비스로 관리 |
