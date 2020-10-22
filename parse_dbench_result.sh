#!/bin/bash

if [ $# -eq 0 ]
then
  echo "Parse dbench result from file to a markdown table"
  echo "Usage: $0 <dbench result file>"
  exit 1
fi

f="$1"
count=$(cat $f | grep "^Random" | wc -l)
test=$(cat $f | grep "^Test" | awk -F ':' '{print $2}')
random_read=$(cat $f | grep "^Random" | awk -F ':' '{print $2}' | awk '{print $1}' | cut -d '/' -f1,1)
random_write=$(cat $f | grep "^Random" | awk -F ':' '{print $2}' | awk '{print $1}' | cut -d '/' -f2,2 | sed 's/.$//')
latency_read=$(cat $f | grep "^Average" | awk -F ':' '{print $2}' | awk '{print $1}' | cut -d '/' -f1,1)
latency_write=$(cat $f | grep "^Average" | awk -F ':' '{print $2}' | awk '{print $1}' | cut -d '/' -f2,2)
seq_read=$(cat $f | grep "^Sequential" | awk -F ':' '{print $2}' | cut -d '/' -f1,1 | sed 's/MiB$//')
seq_write=$(cat $f | grep "^Sequential" | awk -F ':' '{print $2}' | cut -d '/' -f3,3 | sed 's/MiB$//')
mixed_read=$(cat $f | grep "^Mixed" | awk -F ':' '{print $2}' | awk '{print $1}' | cut -d '/' -f1,1)
mixed_write=$(cat $f | grep "^Mixed" | awk -F ':' '{print $2}' | awk '{print $1}' | cut -d '/' -f2,2)

printf "| %-50s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s |\n" "Storage" "random read IOPS" "random write IOPS" "latency read USEC" "latency write USEC" "sequential read MBPS" "sequential write MBPS" "mixed read IOPS" "mixed write IOPS"
printf "| %-50s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s |\n" "------------------------------------" "------" "------" "------" "------" "------" "------" "------" "------"
  
i=1
while [ $i -le $count ]
do
  t=$(echo "$test" | sed -n "$i p" )
  rr=$(echo "$random_read" | sed -n "$i p")
  rw=$(echo "$random_write" | sed -n "$i p")
  lr=$(echo "$latency_read" | sed -n "$i p")
  lw=$(echo "$latency_write" | sed -n "$i p")
  sr=$(echo "$seq_read" | sed -n "$i p")
  sw=$(echo "$seq_write" | sed -n "$i p")
  mr=$(echo "$mixed_read" | sed -n "$i p")
  mw=$(echo "$mixed_write" | sed -n "$i p")
  printf "| %-50s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s |\n" "$t" "$rr" "$rw" "$lr" "$lw" "$sr" "$sw" "$mr" "$mw"
  let i=i+1
done
