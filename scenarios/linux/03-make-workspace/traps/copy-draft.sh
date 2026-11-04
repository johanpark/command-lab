# 설명: draft.md 를 이동하지 않고 복사하면 홈에 그대로 남는다
# 실패해야: 더 이상 홈에 없다
cd ~ && mkdir -p blog/{posts,images,drafts}
cp templates/README.md blog/
cp draft.md blog/posts/2026-hello.md
touch blog/drafts/ideas.md
