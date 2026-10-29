# 해설

```bash
chmod 400 ~/Downloads/shop-prod.pem
ssh -i ~/Downloads/shop-prod.pem ec2-user@ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com 'cat ~/app/RELEASE' > ~/answer.txt
cat >> ~/.ssh/config <<'CFG'
Host shop-prod
    HostName ec2-13-125-41-7.ap-northeast-2.compute.amazonaws.com
    User ec2-user
    IdentityFile ~/Downloads/shop-prod.pem
CFG
ssh shop-prod hostname
```

## EC2 접속 단골 에러
| 에러 | 원인 | 해결 |
|---|---|---|
| `UNPROTECTED PRIVATE KEY FILE` | 키 파일을 남도 읽을 수 있음 | `chmod 400 키.pem` (Windows 는 파일 속성 → 보안에서 내 계정만) |
| `Permission denied (publickey)` | 사용자 이름이 틀림, 또는 다른 키 | AMI 별 기본 사용자 확인, 키 페어 이름 확인 |
| `Connection timed out` | 보안 그룹에서 22번이 안 열림, 퍼블릭 IP 없음 | 보안 그룹 인바운드 (AWS 환경의 보안 그룹 시나리오 참고) |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | 같은 주소에 새 서버 (재생성) | `ssh-keygen -R 주소` 로 옛 지문 지우기 |

## AMI 별 기본 사용자
| OS | 사용자 |
|---|---|
| Amazon Linux | `ec2-user` |
| Ubuntu | `ubuntu` |
| Debian | `admin` |
| RHEL | `ec2-user` |

## 요즘 방식: 키 없이 접속
- **EC2 Instance Connect**: 접속할 때마다 일회용 키를 넣어 줌
- **SSM Session Manager**: 22번 포트를 아예 닫고 `aws ssm start-session --target i-...` 로 접속. 키 파일 분실·유출 걱정이 없고 접속 기록이 남아요.

.pem 파일은 **다시 내려받을 수 없어요.** 잃어버리면 그 키로는 영영 못 들어가니 안전한 곳(비밀번호 관리자 등)에 보관하세요.
