# 처음 받은 AWS 계정 둘러보기

전임자에게서 회사 AWS 계정을 넘겨받았어요. 웹 콘솔 대신 **AWS CLI**(`aws` 명령)로 어떤 자원이 있는지 파악해 봅시다. 리전은 **서울(ap-northeast-2)** 로 설정돼 있어요.

> 이 실습 환경의 AWS 는 컨테이너 안에서 돌아가는 **가짜 AWS** 예요. 명령은 진짜와 똑같지만 요금도 안 나오고 무엇을 지워도 괜찮아요.

## 목표
1. **지금 실행 중(running)인** EC2 인스턴스가 몇 대인지 → `~/running.txt`
2. 이름(`Name` 태그)이 **`payment-api`** 인 인스턴스의 **ID**(`i-...`) → `~/answer.txt`
3. S3 **버킷 이름 목록** (한 줄에 하나) → `~/buckets.txt`

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ec2 describe-instances` | 인스턴스 정보 (아주 긴 JSON) |
| `... --output table` / `--output text` | 표로 / 탭으로 구분된 글자로 |
| `... --query 'Reservations[].Instances[].[InstanceId,State.Name]'` | 원하는 칸만 뽑기 (JMESPath) |
| `... --filters Name=instance-state-name,Values=running` | 조건으로 거르기 (AWS 쪽에서) |
| `... --filters Name=tag:Name,Values=payment-api` | 태그로 거르기 |
| `aws s3 ls` | 버킷 목록 |
| `aws s3api list-buckets --query 'Buckets[].Name' --output text` | 버킷 이름만 |
