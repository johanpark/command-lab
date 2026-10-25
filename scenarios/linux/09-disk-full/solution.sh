big=$(find ~/app -type f -printf '%s %p\n' | sort -rn | head -n 1 | cut -d' ' -f2-)
echo "$big" > ~/answer.txt
rm "$big"
