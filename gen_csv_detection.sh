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
iterations="10000"

function main {

  echo "Launching target program..."
  $prog >/dev/null & pid=$!

  mkdir -p dataset

  echo -n "Monitor started..."
  #Usage: monitor pid resolution iteration
  monitor $pid 1000 $iterations "NA"
  monitor $pid 1000 $iterations "NA"
  monitor $pid 2500 $iterations "NA"
  monitor $pid 7500 $iterations "NA"
  monitor $pid 10000 $iterations "NA"
  monitor $pid 5000 $iterations "NA"
  echo "Done!"

  # Attack
  single_probe_spy/spy $prog $(cat input_A.txt) >/dev/null & spy_pid=$!

  echo -n "Monitor started under attack..."
  #Usage: monitor pid resolution iteration
  monitor $pid 1000 $iterations "A"
  monitor $pid 1000 $iterations "A"
  monitor $pid 2500 $iterations "A"
  monitor $pid 7500 $iterations "A"
  monitor $pid 10000 $iterations "A"
  monitor $pid 5000 $iterations "A"
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
