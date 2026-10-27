line=$(lsof +L1 2>/dev/null | grep app.log | head -n 1)
name=$(awk '{print $1}' <<< "$line"); pid=$(awk '{print $2}' <<< "$line"); fd=$(awk '{print $4}' <<< "$line" | tr -dc '0-9')
ps -p "$pid" -o comm= > ~/answer.txt
: > "/proc/$pid/fd/$fd"
