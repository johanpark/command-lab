cd ~/todo-app
GIT_SEQUENCE_EDITOR="sed -i '2,\$ s/^pick/squash/'" GIT_EDITOR=true git rebase -q -i main
git commit -q --amend -m "로그인 기능 추가"
