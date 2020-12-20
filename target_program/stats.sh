#!/usr/bin/zsh

dir="result100"
# Stats for long running processes
# $1 program name
# $2 output file name
function stats {
  ./$1 > /dev/null & local pid=$!
  perf stat -e cache-references,cache-misses,LLC-prefetches,L1-dcache-misses -p $pid -r 100 -o $2 --append sleep 1
  perf stat -e cycles,instructions,page-faults -p $pid -r 100 -o $2 --append sleep 1
  kill $pid
}

mkdir $dir
stats $1 "${dir}/${1}-stats.txt"
echo "stress test"
stress -m 1 -c 1 &
sleep 1
stats $1 "${dir}/${1}-stats-stress.txt"
killall stress
sleep 1
echo "spy test"
# check jle instruction using gdb -> 0x3192; this will change based on application
../single_probe_spy/spy ./$1 0x3192 > /dev/null & spyid=$!
stats $1 "${dir}/${1}-stats-spy.txt"
kill $spyid
echo "done"


