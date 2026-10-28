find ~/reports -name '*.csv' -print0 | xargs -0 cat | wc -l > ~/answer.txt
find ~/reports -name '*.csv' -print0 | xargs -0 gzip
