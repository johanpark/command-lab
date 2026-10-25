grep -c ERROR ~/logs/app.log > ~/answer.txt
tail -n 20 ~/logs/app.log > ~/recent.log
grep ERROR ~/logs/app.log > ~/errors.log
