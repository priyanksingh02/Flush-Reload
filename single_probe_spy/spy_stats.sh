#!/usr/bin/zsh

output_file="stats.txt"
./spy ../target_program/auto 0x3192 > /dev/null & spyid=$!
perf stat -e cache-references,cache-misses,LLC-prefetches,L1-dcache-misses -p $spyid -r 100 -o $output_file --append sleep 1
../target_program/auto > /dev/null & pid=$!
perf stat -e cache-references,cache-misses,LLC-prefetches,L1-dcache-misses -p $spyid -r 100 -o $output_file --append sleep 1
kill $pid $spyid

