gp2 만, 보류 태그와 함께 보기:
`aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query "Volumes[].[VolumeId,Size,Tags[?Key=='Name']|[0].Value,Tags[?Key=='Migration']|[0].Value]" --output table`
---
보류가 아닌 gp2 만 고르는 JMESPath (태그 값 비교는 작은따옴표 문자열):
`--query "Volumes[?!(Tags[?Key=='Migration' && Value=='hold'])].VolumeId" --output text`
같은 조건에 `sum(...Size)` 를 쓰면 크기 합계도 나와요. **바꾸기 전에** 합계를 구해 두세요 (바꾼 뒤엔 gp2 필터에 안 걸려요).
---
`for v in <위 결과>; do aws ec2 modify-volume --volume-id $v --volume-type gp3; done`
절감액: `python3 -c 'print(round(<합계> * (0.114 - 0.0912), 2))'` → `~/saving.txt`
