cd ~/pricing
first=$(git rev-list --max-parents=0 HEAD)
git bisect start HEAD "$first" > /dev/null 2>&1
git bisect run ./test.sh > /tmp/bisect.out 2>&1
grep -o '^[0-9a-f]\{40\} is the first bad commit' /tmp/bisect.out | cut -c1-12 > ~/answer.txt
git bisect reset > /dev/null 2>&1
