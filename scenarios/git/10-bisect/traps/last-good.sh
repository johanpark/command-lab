# 설명: 'first bad' 대신 마지막으로 괜찮았던 커밋(바로 앞)을 적는다
# 실패해야: 처음 깨진 커밋 해시
cd ~/pricing
first=$(git rev-list --max-parents=0 HEAD)
git bisect start HEAD "$first" > /dev/null 2>&1
git bisect run ./test.sh > /tmp/bisect.out 2>&1
bad=$(grep -o '^[0-9a-f]\{40\} is the first bad commit' /tmp/bisect.out | cut -c1-40)
git rev-parse --short=12 "$bad^" > ~/answer.txt
git bisect reset > /dev/null 2>&1
