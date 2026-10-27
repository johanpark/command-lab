`Select-String -Path ~/configs/*.ini -Pattern 'password='` 를 실행해 보세요. `파일:줄번호:내용` 으로 나와요. 결과 객체에는 `Filename`, `LineNumber`, `Line` 속성이 있어요.
---
`Select-String ... | Select-Object -ExpandProperty Filename -Unique | Set-Content ~/leaks.txt`. 주석 처리된 `# password=` 도 걸리는지 확인해 보세요. 주석은 "평문 비밀번호"가 아니라서 빼야 해요. 패턴을 `'^password='` 로 바꿔 보세요.
---
⚠️ 함정: `Get-Content f | ... | Set-Content f` 처럼 **같은 파일을 읽으면서 쓰면** Windows 에서는 "다른 프로세스가 사용 중" 에러가 나고, 큰 파일은 내용이 깨질 수 있어요. (이 리눅스 실습 환경에선 파일이 작아서 우연히 될 수도 있어요) 괄호로 감싸서 **먼저 다 읽는** 습관을: `(Get-Content f) -replace ... | Set-Content f`
---
`Get-ChildItem ~/configs/*.ini | ForEach-Object { (Get-Content $_.FullName) -replace 'http://', 'https://' | Set-Content $_.FullName }`. 확인: `Select-String -Path ~/configs/*.ini -Pattern 'http://'` 가 아무것도 안 나오면 성공!
