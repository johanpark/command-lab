# 해설

```bash
cd ~/webapp
ls          # README.md  logs  public  src   ← 설정 파일이 안 보임
ls -la      # .env  .env.bak  .env.example  .gitignore ... 까지 보임
cat .env
echo 15xxx > ~/answer.txt
```

## 기억할 것
- 리눅스에서 이름이 `.` 으로 시작하면 **숨김 파일**입니다. 설정 파일(`.bashrc`, `.gitignore`, `.env` 등)이 대부분 이렇게 생겼어요.
- `ls -la` 출력 읽는 법:
  ```
  -rw-r--r-- 1 learner learner 62 Oct 25 10:00 .env
  │└─권한──┘   소유자  그룹    크기 수정시각      이름
  └ 종류 (- 파일, d 디렉터리, l 링크)
  ```
- `.` (현재 폴더) 와 `..` (상위 폴더) 도 `ls -a` 에 항상 보입니다. `ls -A` 는 이 둘을 빼고 보여줘요.
- 실제 서비스에서는 `.env.example`(예시), `.env.bak`(백업)처럼 비슷한 파일이 많습니다. 수정 시각과 이름으로 **진짜 쓰이는 파일**을 구분하는 습관이 중요해요.
