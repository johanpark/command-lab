먼저 전체를 표로: `aws ec2 describe-volumes --query "Volumes[].[VolumeId,State,Size,Tags[?Key=='Name']|[0].Value,Tags[?Key=='Keep']|[0].Value]" --output table`
---
지울 대상: `available` 이면서 `Keep=true` 가 아닌 것.
```
aws ec2 describe-volumes --filters Name=status,Values=available \
  --query "Volumes[?!(Tags[?Key=='Keep' && Value=='true'])].[VolumeId,Size]" --output text
```
---
**지우기 전에** 용량 합계부터 계산해 두세요 (지운 뒤엔 정보가 없어요): 같은 조건에 `--query "sum(Volumes[?!(Tags[?Key=='Keep' && Value=='true'])].Size)"` → `~/freed.txt`
---
`delete-volume` 은 한 번에 하나라서 반복문으로: `for v in $(위 명령의 VolumeId 만 --output text); do aws ec2 delete-volume --volume-id $v; done`
