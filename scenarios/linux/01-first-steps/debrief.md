# 해설

```bash
pwd                      # /home/learner
ls                       # projects  README.txt
cat README.txt
cd projects
ls                       # alpha  beta  gamma
cd beta/docs             # 여러 단계를 한 번에 이동
cat memo.txt
echo sunflower-123 > ~/answer.txt
```

## 기억할 것
- **절대 경로**는 `/` 로 시작 (`/home/learner/projects`), **상대 경로**는 지금 위치 기준 (`beta/docs`).
- `~` 는 내 홈 디렉터리, `..` 은 상위 폴더, `.` 은 현재 폴더.
- `>` 는 명령의 출력을 파일에 **덮어쓰기**로 저장합니다. (`>>` 는 이어 붙이기)
- 탭(Tab) 키를 누르면 파일/폴더 이름이 자동 완성됩니다. 오타를 줄이는 최고의 습관이에요.
