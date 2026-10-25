# 해설

```bash
cd ~
mkdir -p blog/posts blog/images blog/drafts
cp templates/README.md blog/
mv draft.md blog/posts/2026-hello.md
touch blog/drafts/ideas.md
tree blog
```

## 다른 방법
```bash
mkdir -p ~/blog/{posts,images,drafts}     # 중괄호 확장: posts, images, drafts 세 개로 펼쳐짐
```

## 기억할 것
- `cp` 는 원본이 남고, `mv` 는 원본이 사라집니다. **이름 변경 = 같은 곳으로 mv** 예요.
- 대상이 이미 있는 폴더면 그 안으로 들어가고(`cp a.txt dir/`), 없는 이름이면 그 이름으로 만들어집니다.
- `cp`/`mv` 는 같은 이름 파일을 **묻지 않고 덮어씁니다**. 불안하면 `-i` 옵션(덮어쓰기 전에 확인)을 쓰세요.
- 폴더를 통째로 복사할 때는 `cp -r`.
