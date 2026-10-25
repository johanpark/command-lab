name=$(ps -eo comm --sort=-%cpu | sed -n 2p)
echo "$name" > ~/answer.txt
pkill -x "$name"
