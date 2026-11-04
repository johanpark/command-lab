# 설명: bisect 를 끝내고 reset 하지 않으면 엉뚱한 커밋에 머물러 있다
# 실패해야: bisect 가 끝났다
# 실패해야: 원래 위치에 있다
cd ~/pricing
first=$(git rev-list --max-parents=0 HEAD)
git bisect start HEAD "$first" > /dev/null 2>&1
git bisect run ./test.sh > /tmp/bisect.out 2>&1
grep -o '^[0-9a-f]\{40\} is the first bad commit' /tmp/bisect.out | cut -c1-12 > ~/answer.txt
