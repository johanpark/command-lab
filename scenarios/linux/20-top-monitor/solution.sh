sleep 3
ps -eo comm --sort=-rss | sed -n 2p > ~/mem.txt
ps -eo comm,time --sort=-time | awk 'NR == 2 { print $1 }' > ~/cpu.txt
top -b -n 1 > ~/top-report.txt
