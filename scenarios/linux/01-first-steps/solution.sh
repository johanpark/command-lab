# 모범 풀이 (lab test 에서 학습자 권한으로 실행됨)
cd ~/projects/beta/docs
grep '암호' memo.txt | awk '{print $NF}' > ~/answer.txt
