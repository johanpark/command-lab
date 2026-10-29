# 붙어 있지 않은 EBS 볼륨 정리 (비용 절감)

EBS 볼륨은 EC2 에 붙이는 **디스크**예요. 서버를 지워도 디스크는 따로 남는 경우가 많고, 아무 데도 안 붙어 있어도 **용량만큼 매달 요금**이 나가요.

## 목표
1. 어디에도 붙어 있지 않은(**`available`** 상태) 볼륨을 찾아 **지우세요.**
2. 단, **`Keep=true`** 태그가 있는 볼륨은 보존해야 해요. (DB 복구용 디스크)
3. 서버에 **붙어 있는(`in-use`) 볼륨은 절대 건드리지 마세요.**
4. 이번에 지운 볼륨들의 **용량 합계(GiB, 숫자만)** 를 `~/freed.txt` 에 저장하세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-volumes --query 'Volumes[].[VolumeId,State,Size,Tags]'` | 볼륨 목록 |
| `--filters Name=status,Values=available` | 붙어 있지 않은 것만 |
| `--query "Volumes[?!(Tags[?Key=='Keep' && Value=='true'])]"` | Keep=true 가 아닌 것만 |
| `--query 'sum(Volumes[].Size)'` | 용량 합계 (JMESPath) |
| `aws ec2 delete-volume --volume-id vol-...` | 지우기 (한 번에 하나) |
