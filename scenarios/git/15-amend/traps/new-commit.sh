# 설명: --amend 대신 새 커밋을 하나 더 만든다
# 실패해야: push 안 했던 커밋이 여전히 하나
cd ~/blog
git add login.css
git commit -qm "로그인 페이지 추가"
git push -q origin main
