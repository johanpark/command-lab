sed -i 's|^docker run -d --name web|docker rm -f web 2>/dev/null \|\| true\ndocker run -d --name web|' ~/deploy.sh
~/deploy.sh 1.1
sleep 1
