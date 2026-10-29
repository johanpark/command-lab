# .pem 키로 EC2 서버 접속하기

새로 만든 운영 서버(EC2)에 처음 접속해야 해요. AWS 콘솔에서 키 페어를 만들 때 받은 **`~/Downloads/shop-prod.pem`** 이 있고, 서버 정보는 이래요.

| 항목 | 값 |
|---|---|
| 퍼블릭 DNS | `ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com` |
| OS (AMI) | **Amazon Linux 2023** |

그런데 접속이 안 돼요.
```
$ ssh -i ~/Downloads/shop-prod.pem ubuntu@ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com
WARNING: UNPROTECTED PRIVATE KEY FILE!
Permissions 0644 for '/home/learner/Downloads/shop-prod.pem' are too open.
```

## 목표
1. 서버에 접속해서 **`~/app/RELEASE` 파일의 내용**(서버 쪽 홈 폴더)을 읽어 내 컴퓨터의 `~/answer.txt` 에 저장하세요.
2. 다음부터는 `ssh shop-prod` 만 쳐도 접속되게 **`~/.ssh/config`** 에 별칭을 만드세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `ls -l 키파일` | 권한 확인 |
| `chmod 400 키파일` | 나만 읽기 |
| `ssh -i 키파일 사용자@주소` | 키로 접속 (`exit` 로 나오기) |
| `ssh -i 키파일 사용자@주소 'cat 파일'` | 접속해서 명령 하나만 실행하고 결과 받기 |
| `ssh -G 별칭` | 별칭의 최종 설정 확인 |
