#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
S=/opt/cmdlab/secret; Z=$(secret_get zid); ZN=$(secret_get zone); P=$(secret_get primary); B=$(secret_get backup)
RS=$(aws route53 list-resource-record-sets --hosted-zone-id "$Z" --output json 2>/dev/null)
api=$(jq -c --arg n "api.$ZN." '[.ResourceRecordSets[] | select(.Name == $n and .Type == "A")]' <<< "$RS")
plain=$(jq '[.[] | select(.Failover == null)] | length' <<< "$api")
pri=$(jq -c '.[] | select(.Failover == "PRIMARY")' <<< "$api")
sec=$(jq -c '.[] | select(.Failover == "SECONDARY")' <<< "$api")
[ "$plain" = 0 ] && pass "api 의 일반 A 레코드를 없앴다" || fail "api 의 일반 A 레코드를 없앴다 (아직 있어요. 장애 조치 레코드와 같이 있으면 안 돼요)"
if [ -z "$pri" ]; then fail "PRIMARY 레코드가 운영 서버를 가리키고 헬스 체크가 붙어 있다 (PRIMARY 가 없어요)"
else
  ip=$(jq -r '.ResourceRecords[0].Value' <<< "$pri"); hc=$(jq -r '.HealthCheckId // empty' <<< "$pri")
  if [ "$ip" != "$P" ]; then fail "PRIMARY 레코드가 운영 서버를 가리키고 헬스 체크가 붙어 있다 (IP: $ip)"
  elif [ -z "$hc" ]; then fail "PRIMARY 레코드가 운영 서버를 가리키고 헬스 체크가 붙어 있다 (헬스 체크가 없으면 장애를 알 수 없어요)"
  else
    cfg=$(aws route53 get-health-check --health-check-id "$hc" --query HealthCheck.HealthCheckConfig --output json 2>/dev/null)
    bad=$(jq -r --arg p "$P" '[
      (if .IPAddress != $p then "IP(\($p))" else empty end),
      (if .Type != "HTTPS" then "종류(HTTPS)" else empty end),
      (if .Port != 443 then "포트(443)" else empty end),
      (if .ResourcePath != "/health" then "경로(/health)" else empty end),
      (if .RequestInterval != 30 then "간격(30초)" else empty end),
      (if .FailureThreshold != 3 then "실패 횟수(3)" else empty end)] | join(", ")' <<< "${cfg:-{\}}")
    [ -z "$cfg" ] && bad="헬스 체크가 없어요"
    [ -z "$bad" ] && pass "PRIMARY 레코드가 운영 서버를 가리키고 헬스 체크가 붙어 있다" \
      || fail "PRIMARY 레코드가 운영 서버를 가리키고 헬스 체크가 붙어 있다 (헬스 체크가 계획과 달라요: $bad)"
  fi
fi
if [ -z "$sec" ]; then fail "SECONDARY 레코드가 예비 서버를 가리킨다 (SECONDARY 가 없어요)"
else
  ip=$(jq -r '.ResourceRecords[0].Value' <<< "$sec")
  [ "$ip" = "$B" ] && pass "SECONDARY 레코드가 예비 서버를 가리킨다" || fail "SECONDARY 레코드가 예비 서버를 가리킨다 (IP: $ip)"
fi
ttl=$(jq -r '[.[] | select(.Failover) | .TTL] | unique | map(tostring) | join(",")' <<< "$api")
[ "$ttl" = 60 ] && pass "장애 조치 레코드의 TTL 이 60 이다" || fail "장애 조치 레코드의 TTL 이 60 이다 (지금: ${ttl:-없음})"
[ "$(jq -c '[.ResourceRecordSets[] | select(.Name | startswith("api.") | not)] | sort_by(.Name, .Type)' <<< "$RS")" = "$(cat $S/keep)" ] \
  && pass "www, MX 레코드는 그대로다" || fail "www, MX 레코드는 그대로다"
finish
