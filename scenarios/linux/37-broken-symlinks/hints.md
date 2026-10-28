`ls -la ~/site` 에서 `->` 가 붙은 줄이 링크예요. `find ~/site -type l -exec ls -l {} +` 로 모든 링크와 대상을 한 번에 볼 수 있어요.
---
`find ~/site -xtype l` 은 "따라가 봐도 여전히 링크" = 대상이 없는 링크만 보여 줘요. `.env` 같은 **숨김 파일**, 깨진 링크를 가리키는 **링크의 링크**도 잡아 줘요. 개수: `find ~/site -xtype l | wc -l`
---
uploads 는 지우기 **전에** 고치세요: `ln -sfn /srv/uploads ~/site/releases/v3/uploads` (`-f` 덮어쓰기, `-n` 링크가 폴더를 가리켜도 그 안으로 들어가지 않기)
---
나머지 삭제: `find ~/site -xtype l -delete`. 지우기 전에 `-delete` 없이 한 번 더 목록을 확인하세요!
