`ls ~/tools/bin` 으로 파일이 정말 있는지, `~/tools/bin/deploytool --version` 처럼 전체 경로로는 실행되는지 확인해 보세요.
---
셸은 `$PATH` 에 적힌 폴더에서만 명령어를 찾아요. `echo $PATH` 에 `~/tools/bin` 이 없죠? `export PATH="$PATH:$HOME/tools/bin"` 을 실행하면 지금 터미널에서는 해결돼요.
---
⚠️ `export PATH=~/tools/bin` 처럼 `$PATH:` 를 빼면 기존 폴더가 전부 사라져서 `ls` 도 안 돼요. 그랬다면 `exit` 로 나갔다가 다시 들어오면 원래대로 돌아와요.
---
새 터미널에서도 유지하려면 `~/.bashrc` 끝에 추가: `echo 'export PATH="$PATH:$HOME/tools/bin"' >> ~/.bashrc` → `source ~/.bashrc` → `deploytool --version > ~/answer.txt`
