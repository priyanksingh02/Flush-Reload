#!/usr/bin/zsh

prog="auto"
./$prog > /dev/null & pid=$!
perf stat -e cycles,cache-references,cache-misses,instructions,page-faults -p $pid -o repeat-stats.txt --append sleep 1
perf stat -e cycles,cache-references,cache-misses,instructions,page-faults -p $pid -r 10 -o repeat-stats.txt --append sleep 1
perf stat -e cycles,cache-references,cache-misses,instructions,page-faults -p $pid -r 50 -o repeat-stats.txt --append sleep 1
perf stat -e cycles,cache-references,cache-misses,instructions,page-faults -p $pid -r 100 -o repeat-stats.txt --append sleep 1
kill $pid
