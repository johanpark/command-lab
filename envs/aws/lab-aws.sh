# AWS 환경 시나리오의 setup/check 에서 쓰는 도우미 (source /usr/local/lib/lab-aws.sh)

# 가짜 AWS(moto) 서버가 뜰 때까지 기다린다
wait_aws() {
  local i
  for i in $(seq 1 60); do
    curl -fs -o /dev/null "$AWS_ENDPOINT_URL/moto-api/" && return 0
    sleep 0.5
  done
  echo "가짜 AWS 서버(moto)가 뜨지 않았어요. /var/log/moto.log 를 확인하세요." >&2
  return 1
}

# 실습용 EC2 이미지(AMI) 하나 (moto 가 미리 갖고 있는 것 중 첫 번째)
lab_ami() { aws ec2 describe-images --owners amazon --query 'Images[0].ImageId' --output text; }
