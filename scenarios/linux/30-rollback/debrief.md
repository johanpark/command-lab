# 해설

```bash
ls -l ~/app                                # current -> releases/2.4.0
cd ~/app
ln -sfn releases/2.3.1 current             # 링크만 바꾸기 (1초)
readlink current                           # releases/2.3.1
./restart.sh
curl localhost:8080/version.txt            # 2.3.1
diff -r releases/2.3.1 releases/2.4.0      # Only in releases/2.3.1/public: health
```

## 왜 이런 구조로 배포할까?
- **배포** = 새 폴더에 풀고 링크만 바꾸기 → 파일을 덮어쓰는 중간 상태가 없어요.
- **롤백** = 링크를 예전 폴더로 되돌리기 → 몇 초면 끝나요.
- 예전 버전이 그대로 남아 있어서 **비교·분석**이 쉬워요.

Capistrano, Deployer 같은 배포 도구들이 다 이 방식(`releases/` + `current`)을 써요.

## 함정 포인트: ln 의 `-n`
`current` 가 이미 **폴더를 가리키는 링크**일 때 `ln -sf releases/2.3.1 current` 를 하면, ln 은 `current` 를 "폴더"로 보고 **그 안에** `2.3.1` 링크를 만들어요. 결과: `releases/2.4.0/2.3.1 -> ...` 가 생기고 current 는 그대로. `-n` (no-dereference) 은 "링크를 따라 들어가지 말고 링크 자체를 바꿔라"는 뜻이에요.

## 롤백 다음에 할 일
1. 원인 기록 (이번엔 `health` 파일이 빌드에서 빠짐)
2. 빌드/배포 파이프라인에 "필수 파일 확인" 단계 추가
3. 고친 2.4.1 을 새로 배포
