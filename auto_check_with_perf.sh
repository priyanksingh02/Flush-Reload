#!/usr/bin/env bash

# No attack
# Duraitons : 100 250 500 750 1000
# Iterations : 10,000
# NA : No Attack
# A : Under attack

# don't use abcd program as it requires user input
prog="target_program/auto"
# Refer to side-channel-detector repo to get `mon` program
mon_prog="../../bin/mon"
iterations="10"

function main {

  echo "Launching target program..."
  $prog >/dev/null & pid=$!

  perf stat -e cache-misses,cache-references -p $pid sleep 0.01 | tee "${pid}_perf_auto.txt" # 10 msec
  perf stat -e cache-misses,cache-references -p $pid sleep 0.1 | tee --append  "${pid}_perf_auto.txt" # 100 msec
  mv "${pid}_perf_auto.txt" dataset/

  echo -n "Monitor started..."
  #Usage: monitor pid resolution iteration
  monitor $pid 10000 $iterations "NA" # 10 msec
  monitor $pid 100000 $iterations "NA" # 100 msec
  echo "Done!"

  # Attack
  single_probe_spy/spy $prog $(cat input_A.txt) >/dev/null & spy_pid=$!

  echo -n "Monitor started under attack..."
  #Usage: monitor pid resolution iteration
  monitor $pid 10000 $iterations "A" # 10 msec
  monitor $pid 100000 $iterations "A" # 100 msec
  echo "Done!"

  echo -n "Killing $pid $spy_pid"
  kill -SIGTERM $pid $spy_pid
  echo " Done!"

}

function monitor {
  [[ -x $mon_prog ]] || (echo "Monitor Program missing" && exit 1)
  $mon_prog $1 $2 $3
  mv output.csv "dataset/$4_$1_$2_$3.csv"
}

main "$@"
