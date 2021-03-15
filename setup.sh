#!/usr/bin/env bash

root_dir=$(pwd)

function main {
  # ./setup.sh clean
  # Equivalent to make clean
  if [[ "$1" == "clean" ]]; then
    make_all clean
    exit
  fi

  echo "PROJECT DIR: $root_dir"
  cd $root_dir || (echo "Error: cd into root_dir failed!" && exit)
  make_all
  calibrate
  extract_address "target_program/auto" "input_A"
  extract_address "target_program/auto" "input_B"
  extract_address "target_program/auto" "input_C"
  extract_address "target_program/auto" "input_D"

  mkdir -p dataset
}

function calibrate {
  echo -n "Calibrating..."
  $root_dir/calibration/calibration 2> /dev/null | tee threshold.txt
  echo "Done!"
}

function make_all {
  local sub_folders=(calibration multi_probe_spy single_probe_spy target_program)
  for folder in ${sub_folders[*]}; do
    make "$@" -C $folder
  done
}

function extract_address {
  gdb -batch -ex "file $1" -ex "disassemble $2" | grep jle | awk '{print $1}' | tee "$2.txt"
}

main "$@"
