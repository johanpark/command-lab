`sudo echo x >> 파일` 에서 `sudo` 가 붙는 건 `echo` 뿐이에요. `>> 파일` (리다이렉션)은 **지금 내 셸(learner)** 이 처리해요. 그래서 파일을 여는 순간 권한이 없어요.
---
파일을 여는 쪽을 root 로 바꾸면 돼요. `tee` 는 받은 입력을 파일에 써 주는 명령이라 `sudo tee` 로 실행하면 root 가 파일을 열어요.
---
⚠️ `tee` 는 기본이 **덮어쓰기**예요! 추가하려면 `-a`: `echo "1.2.3.4" | sudo tee -a /etc/app/allowed_ips`. 화면에도 찍히는 게 싫으면 끝에 `> /dev/null`.
---
새 파일: `printf 'MAINTENANCE=on\nUNTIL=06:00\n' | sudo tee /etc/app/maintenance.conf`. 끝나면 `cat` 으로 내용과 `ls -l` 로 소유자를 확인하세요.
