# 디스크 요금 20% 줄이기 (EBS gp2 → gp3 전환)

EBS 의 **gp3** 는 gp2 보다 **약 20% 싸면서** 기본 성능은 같거나 더 좋아요. 그런데 이 계정의 디스크는 아직 대부분 gp2 예요.
gp2 → gp3 는 **서버를 멈추지 않고** 바꿀 수 있어요. 메모는 `~/ebs-memo.md` 에 있어요.

## 목표
1. **gp2 볼륨을 gp3 로** 바꾸세요. (서버에 붙어 있는 것도, 아닌 것도)
2. `Migration=hold` 태그가 있는 볼륨과 gp2 가 아닌 볼륨(io1 등)은 그대로 두세요.
3. 이번에 바꾼 볼륨들로 **한 달에 아끼는 금액**(달러, 소수점 둘째 자리)을 `~/saving.txt` 에 숫자만 적으세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-volumes --query "Volumes[].[VolumeId,VolumeType,Size,State,Tags[?Key=='Name']\|[0].Value]" --output table` | 볼륨 목록 |
| `--filters Name=volume-type,Values=gp2` | gp2 만 |
| `aws ec2 modify-volume --volume-id vol-... --volume-type gp3` | 타입 바꾸기 (온라인) |
| `aws ec2 describe-volumes-modifications --volume-ids vol-...` | 변경 진행 상황 |
| `--query "sum(Volumes[].Size)"` / `python3 -c 'print(...)'` | 합계, 계산 |
