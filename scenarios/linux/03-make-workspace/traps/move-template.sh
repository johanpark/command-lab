# 설명: 템플릿을 복사하지 않고 이동하면 원본이 사라진다
# 실패해야: 원본 ~/templates/README.md
cd ~ && mkdir -p blog/{posts,images,drafts}
mv templates/README.md blog/
mv draft.md blog/posts/2026-hello.md
touch blog/drafts/ideas.md
