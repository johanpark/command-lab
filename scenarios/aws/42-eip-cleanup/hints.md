`aws ec2 describe-addresses --query "Addresses[].[AllocationId,AssociationId,InstanceId,Tags[?Key=='Name']|[0].Value]" --output table` 로 한눈에 보세요. `AssociationId` 가 `None` 인 줄이 "아무 데도 안 붙은" 주소예요.
---
⚠️ `InstanceId` 가 비어 있다고 안 쓰는 게 아니에요. NAT 게이트웨이 주소는 서버가 아니라 **네트워크 인터페이스**에 붙어 있어서 `InstanceId` 가 비어 있어요. 반납하려고 하면 `InvalidIPAddress.InUse` 로 거부돼요 (그게 정상!).
---
고를 때 태그도 같이 보세요: `aws ec2 describe-addresses --output json | jq -r '.Addresses[] | select(.AssociationId == null) | [.AllocationId, (.Tags // [] | map("\(.Key)=\(.Value)") | join(","))] | @tsv'`. `Keep=true` 가 있는 줄은 빼고 `aws ec2 release-address --allocation-id ...`
---
old-batch: 서버 ID 를 찾고 (`aws ec2 describe-instances --filters Name=tag:Name,Values=old-batch --query 'Reservations[].Instances[].InstanceId' --output text`), 그 서버에 붙은 주소의 `AssociationId` 로 `disassociate-address` → `AllocationId` 로 `release-address`. 순서를 바꾸면 `InUse` 로 거부돼요.
