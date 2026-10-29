# 해설

```bash
sudo tail -n 30 /var/log/cloud-init-output.log        # ... line 8: DB_HOST: unbound variable
echo DB_HOST > ~/answer.txt
host=$(grep -o 'prod-db[^` ]*' ~/runbook.md | head -1)
sudo sed -i "s/^DB_HOST=.*/DB_HOST=$host/" /opt/shop/config/app.env
sudo chown -R shop:shop /opt/shop
sudo -u shop /opt/shop/bin/start.sh
curl -s localhost:8080/health
# 다음 서버를 위해 user-data 에 값 정의
sudo sed -i "/^set -euxo pipefail/a DB_HOST=$host" /var/lib/cloud/instance/user-data.txt
```

## cloud-init 디버깅 지도
| 어디 | 무엇 |
|---|---|
| `/var/log/cloud-init-output.log` | user-data 스크립트 출력 (가장 먼저 볼 곳) |
| `/var/log/cloud-init.log` | cloud-init 자체의 자세한 기록 |
| `/var/lib/cloud/instance/user-data.txt` | 이번 부팅에 받은 user-data |
| `/var/lib/cloud/instance/scripts/` | 실제로 실행된 스크립트 |
| `cloud-init status --long` | 성공/실패 요약 |

user-data 는 **처음 부팅할 때 한 번만** 실행돼요. 재부팅해도 다시 안 돌아요. 그래서 실패하면 이번처럼 손으로 마무리하거나, 서버를 지우고 고친 템플릿으로 새로 띄워요. (오토스케일링 환경에서는 손으로 고친 서버보다 **새로 띄운 서버**가 믿을 만해요)

## set -euxo pipefail
| 옵션 | 뜻 |
|---|---|
| `-e` | 명령이 실패하면 멈춤 |
| `-u` | 정의 안 된 변수를 쓰면 멈춤 (오타 방지!) |
| `-x` | 실행하는 명령을 `+` 와 함께 출력 (로그에서 위치 추적) |
| `-o pipefail` | 파이프 중간 실패도 실패로 |

이번 장애는 `-u` 가 **오히려 고마운** 경우예요. 없었다면 `DB_HOST=` 가 빈 값으로 들어가 앱이 엉뚱하게 떴을 거예요. 빨리, 분명하게 실패하는 게 낫다(fail fast)는 원칙이에요.

## 설정값은 어디서?
user-data 에 비밀번호나 환경별 값을 적어 두기보다 **SSM Parameter Store** 에서 읽어 오는 게 좋아요.
```bash
DB_HOST=$(aws ssm get-parameter --name /prod/shop/db_host --query Parameter.Value --output text)
```
서버에 붙은 IAM 역할에 `ssm:GetParameter` 권한만 있으면 돼요.
