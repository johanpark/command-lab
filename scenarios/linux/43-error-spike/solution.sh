L=~/logs/access.log
awk '$4 >= 500' $L | cut -c12-16 | sort | uniq -c | sort -rn | head -n 1 | awk '{print $2}' > ~/answer.txt
awk '$4 >= 500' $L | cut -c12-13 | sort | uniq -c | awk '{print $2, $1}' > ~/by_hour.txt
