cd ~/shop
fix=$(git log --format=%h --grep='보안' release/1.0..main)
git switch -q release/1.0
git cherry-pick "$fix" > /dev/null
