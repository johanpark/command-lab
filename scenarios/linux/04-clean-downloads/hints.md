`cd ~/Downloads` 후 `ls` 로 어떤 종류의 파일이 있는지 보세요. 그다음 `mkdir images docs`.
---
`ls *.jpg` 로 패턴이 맞는지 먼저 확인하고 `mv *.jpg images/`. png도 똑같이 하거나 `mv *.jpg *.png images/` 처럼 한 번에!
---
파일 이름에 공백이 있는 것도 있어요. 와일드카드는 공백이 있는 이름도 잘 처리해 줍니다. 대문자 확장자(`.JPG`)도 있는지 `ls` 로 꼭 확인하세요.
---
`mv *.jpg *.JPG *.png images/` → `mv *.pdf docs/` → `ls *.tmp` 확인 후 `rm *.tmp`
