# 해설

```bash
F="Volumes[?!(Tags[?Key=='Migration' && Value=='hold'])]"
T=$(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query "sum($F.Size)" --output text)
for v in $(aws ec2 describe-volumes --filters Name=volume-type,Values=gp2 --query "$F.VolumeId" --output text); do
  aws ec2 modify-volume --volume-id $v --volume-type gp3
done
python3 -c "print(f'{$T * (0.114 - 0.0912):.2f}')" > ~/saving.txt
```

## gp2 vs gp3
| | gp2 | gp3 |
|---|---|---|
| 요금 (서울) | $0.114 / GB | **$0.0912 / GB** |
| IOPS | 크기 × 3 (최소 100, 최대 16,000) | **기본 3,000** + 필요하면 따로 구매 |
| 처리량 | 크기에 따라 | **기본 125 MB/s** + 따로 구매 |

## 주의: 큰 gp2 볼륨
gp2 는 **크기가 클수록 IOPS 가 올라가요.** 2,000 GB gp2 는 6,000 IOPS 인데, 그냥 gp3 로 바꾸면 기본 3,000 IOPS 가 돼서 **느려질 수 있어요.** 1,000 GB 넘는 gp2 는 `--iops`, `--throughput` 을 같이 지정해서 성능을 맞추세요 (그래도 대부분 더 싸요).
(이 실습의 가짜 AWS 는 IOPS 값을 기록하지 않아서 이 부분은 채점하지 않아요)

## 온라인 변경
- `modify-volume` 은 서버를 멈추지 않아요. 상태가 `modifying → optimizing → completed` 로 바뀌고, optimizing 중에도 쓸 수 있어요.
- 같은 볼륨은 **6시간에 한 번**만 바꿀 수 있어요. 한 번에 타입·크기·IOPS 를 같이 정하세요.

## 실무 팁
- 새로 만드는 볼륨이 gp3 가 되도록 시작 템플릿·Terraform 기본값부터 바꾸세요. 안 그러면 gp2 가 계속 생겨요.
- AWS Compute Optimizer 가 "gp2 → gp3 전환 시 예상 절감액" 을 볼륨별로 보여 줘요.
