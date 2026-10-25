awk '{print $1}' ~/access.log | sort | uniq -c | sort -rn | head -n 5 > ~/top5.txt
head -n 1 ~/top5.txt | awk '{print $2}' > ~/answer.txt
