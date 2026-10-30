#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
source /usr/local/lib/lab-aws.sh
set -e
wait_aws
S=/opt/cmdlab/secret
aws dynamodb create-table --table-name products --attribute-definitions AttributeName=sku,AttributeType=S \
  --key-schema AttributeName=sku,KeyType=HASH --billing-mode PAY_PER_REQUEST >/dev/null
names=(무선마우스 기계식키보드 USB허브 모니터암 노트북거치대 웹캠 헤드셋 마우스패드 충전기 HDMI케이블 SSD1TB 외장하드 블루투스스피커 태블릿펜 스마트워치
       보조배터리 LED스탠드 멀티탭 노이즈캔슬링이어폰 게이밍의자 책상정리함 랜카드 공유기 무선충전패드 USB메모리 키캡세트 손목받침대 모니터 프린터 잉크)
batch() { jq -s '{products: [.[] | {PutRequest: {Item: .}}]}' > $S/b.json; aws dynamodb batch-write-item --request-items file://$S/b.json >/dev/null; }
item() { jq -cn --arg s "$1" --arg n "$2" --arg p "$3" --arg st "$4" '{sku: {S: $s}, name: {S: $n}, price: {N: $p}, stock: {N: $st}}'; }
: > $S/all
for i in "${!names[@]}"; do
  printf '%s\t%s\t%s\t%s\n' "P-$((1001 + i))" "${names[$i]}" "$(( $(rand_int 9 300) * 1000 ))" "$(rand_int 0 80)" >> $S/all
done
put_all() { # 가격 보정(원) 줄 범위
  local adj=$1
  sed -n "$2" $S/all | while IFS=$'\t' read -r s n p st; do item "$s" "$n" "$((p + adj))" "$st"; done | batch
}
# 그저께 백업 (가격이 조금 다름) → 어젯밤 백업
put_all 5000 '1,25p'; put_all 5000 '26,30p'
aws dynamodb create-backup --table-name products --backup-name products-nightly-20261027 >/dev/null
sleep 1
put_all 0 '1,25p'; put_all 0 '26,30p'
aws dynamodb create-backup --table-name products --backup-name products-nightly-20261028 >/dev/null
# 오늘: 가격 변경 3건, 신상품 2건
mapfile -t rows < <(shuf -n 11 $S/all)
: > $S/changed; : > $S/deleted
for r in "${rows[@]:0:3}"; do
  IFS=$'\t' read -r s n p st <<< "$r"
  np=$(( p - 2000 ))
  aws dynamodb update-item --table-name products --key "{\"sku\":{\"S\":\"$s\"}}" --update-expression "SET price = :p" \
    --expression-attribute-values "{\":p\":{\"N\":\"$np\"}}"
  echo "$s" >> $S/changed
done
{ item P-2001 "C타입젠더" 6900 120; item P-2002 "모니터클리너" 8900 45; } | batch
# 버그 스크립트: 6~8개 삭제 (오늘 바뀐 것과는 겹치지 않음)
for r in "${rows[@]:3:$(rand_int 6 8)}"; do
  IFS=$'\t' read -r s _ <<< "$r"
  aws dynamodb delete-item --table-name products --key "{\"sku\":{\"S\":\"$s\"}}"
  echo "$s" >> $S/deleted
done
rm -f $S/b.json
# 정답 상태: 오늘 상태 + 어젯밤 백업의 삭제된 상품
{
  aws dynamodb scan --table-name products --output json | jq -c '.Items[]'
  grep -F -f $S/deleted $S/all | while IFS=$'\t' read -r s n p st; do item "$s" "$n" "$p" "$st"; done
} | jq -cS . | sort > $S/expected
mkdir -p "$H"
cat > "$H/incident.txt" <<TXT
[긴급] 오늘 오후 품절 상품 정리 스크립트가 조건을 잘못 읽어서
재고가 있는 상품까지 products 테이블에서 지웠습니다. (삭제 $(wc -l < $S/deleted)건 추정)

- 백업: 매일 밤 products-nightly-YYYYMMDD 로 자동 백업 중 (어젯밤 = 20261028)
- 주의: 오늘 낮에 가격 3건 수정, 신상품 2건 등록이 있었음 → 이 변경은 살려야 함
- 운영 테이블(products)을 통째로 백업으로 바꾸면 오늘 변경이 날아감!
TXT
give "$H/incident.txt"
