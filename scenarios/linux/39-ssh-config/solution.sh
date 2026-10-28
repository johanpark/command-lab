cfg=~/.ssh/config
new=$(awk 'NR > 1 {
  printf "Host %s\n    HostName %s\n    User %s\n    Port %s\n    IdentityFile %s\n\n", $1, $2, $3, $4, $5
}' ~/servers.txt)
{ echo "$new"; echo; cat "$cfg"; } > /tmp/ssh_config.new
cat /tmp/ssh_config.new > "$cfg"
chmod 600 "$cfg"
ssh -G web | grep -E '^(hostname|user|port|identityfile) '
