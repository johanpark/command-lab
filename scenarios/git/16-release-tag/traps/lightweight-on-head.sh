# 설명: -a 없이 HEAD 에 태그를 달면 설명 없는 태그가 엉뚱한 커밋에 붙는다
# 실패해야: 1.2.0 커밋('버전 1.2.0')을 가리킨다
# 실패해야: annotated
cd ~/app
git tag v1.2.0
git push -q origin v1.2.0
