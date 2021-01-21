#!/bin/bash

while true
do
  echo "date: $(date)"
  uptime
  top -b -n 1
  free -m
  ps -ef
  ip addr show
  ip link show
  dmesg -H -l emerg,alert,crit,err,warn
  echo "$(systemctl status kubelet)"
  echo "$(systemctl status docker)"
  docker ps -a
  /usr/bin/kubectl get node -o wide
  /usr/bin/kubectl get pod -A -o wide --field-selector spec.nodeName=$(hostname)
  echo "describe pods start"
  while read line
  do
    ns=$(echo "$line" | awk '{print $1}')
    name=$(echo "$line" | awk '{print $2}')
    /usr/bin/kubectl -n "$ns" describe pod "$name"
  done < <(/usr/bin/kubectl get pod -A --field-selector spec.nodeName=$(hostname) --no-headers)
  echo "describe pods end"
  echo ========================================================================================================================================
  echo ========================================================================================================================================
  echo ========================================================================================================================================
  sleep 5
done