ids=$(aws ecr list-images --repository-name shop-api --filter tagStatus=UNTAGGED --query 'imageIds[].imageDigest' --output text)
aws ecr batch-delete-image --repository-name shop-api --image-ids $(for d in $ids; do echo "imageDigest=$d"; done) >/dev/null
cat > ~/policy.json <<'JSON'
{"rules": [
  {"rulePriority": 1, "description": "태그 없는 이미지 1일",
   "selection": {"tagStatus": "untagged", "countType": "sinceImagePushed", "countUnit": "days", "countNumber": 1},
   "action": {"type": "expire"}},
  {"rulePriority": 2, "description": "dev 이미지 14일",
   "selection": {"tagStatus": "tagged", "tagPrefixList": ["dev-"], "countType": "sinceImagePushed", "countUnit": "days", "countNumber": 14},
   "action": {"type": "expire"}},
  {"rulePriority": 3, "description": "release 최근 10개",
   "selection": {"tagStatus": "tagged", "tagPrefixList": ["release-"], "countType": "imageCountMoreThan", "countNumber": 10},
   "action": {"type": "expire"}}
]}
JSON
aws ecr put-lifecycle-policy --repository-name shop-api --lifecycle-policy-text file://$HOME/policy.json >/dev/null
