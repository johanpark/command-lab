cd ~/webapp
grep DB_PORT .env | cut -d= -f2 > ~/answer.txt
