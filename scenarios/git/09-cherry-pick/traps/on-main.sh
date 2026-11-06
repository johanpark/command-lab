# 설명: release 로 옮기지 않고 main 에서 cherry-pick 을 시도한다
# 실패해야: 보안 수정(login.js)이 들어갔다
cd ~/shop
fix=$(git log --format=%h --grep='보안' release/1.0..main)
git switch -q main
git cherry-pick "$fix" > /dev/null 2>&1 || git cherry-pick --abort 2>/dev/null
