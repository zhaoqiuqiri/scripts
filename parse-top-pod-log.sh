#!/bin/bash

set -x

if [[ $# -ne 2 ]]
then
  echo "Usage: $0 <in file> <out file>"
  exit 1
fi

in="$1"
out="$2"
match=0

rm -rf "$out"
echo "Running-Pods,CPU(m),MEMORY(Mi)" >> $out

cpus=0
mems=0

while read line
do
  if [[ "$line" == "number of running pod"* ]]
  then
    pods=$(echo "$line" | cut -d ':' -f2)
    match=1
    continue
  fi
  
  if [[ $match -gt 0 ]]
  then
    cpu=$(echo "$line" | awk '{print $2}' | tr -d "[:lower:]" | tr -d "[:upper:]")
    mem=$(echo "$line" | awk '{print $3}' | tr -d "[:lower:]" | tr -d "[:upper:]")
    if [[ ! -z "$cpu" ]] && [[ ! -z "$mem" ]]
    then
      let cpus=cpus+cpu
      let mems=mems+mem
    fi

    #echo "$pods,$cpu,$mem" >> $out

    if [[ "$line" == "rook-discover-j6xsk"* ]]
    then
      echo "$pods,$cpus,$mems" >> $out
      cpus=0
      mems=0
      pods=0
      match=0
    fi
  fi
done < "$in"




