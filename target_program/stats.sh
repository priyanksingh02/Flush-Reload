#!/usr/bin/zsh

# Stats for long running processes
# $1 program name
# $2 output file name
function stats {
  ./$1 > /dev/null & local pid=$!
  perf stat -e cache-references,cache-misses -p $pid -r 10 -o $2 --append sleep 1
  perf stat -e cycles -p $pid -r 10 -o $2 --append sleep 1
  perf stat -e instructions -p $pid -r 10 -o $2 --append sleep 1
  perf stat -e page-faults -p $pid -r 10 -o $2 --append sleep 1
  perf stat -e L1-dcache-misses -p $pid -r 10 -o $2 --append sleep 1
  kill $pid
}

stats linear stats.txt
