#!/usr/bin/env bash
FIVE_GB_IN_BYTES="5368709120"

for dev in $(lsblk --all --noheadings --list --output KNAME 2>/dev/null | grep -v "^rbd")
do
  dev_name="/dev/$dev"
  type=$(lsblk "$dev_name" --bytes --nodeps --pairs --paths --output SIZE,ROTA,RO,TYPE,PKNAME,NAME,KNAME 2>/dev/null | awk '{print $4}' | cut -d'=' -f2 | tr -d '"')
  size=$(lsblk "$dev_name" --bytes --nodeps --pairs --paths --output SIZE,ROTA,RO,TYPE,PKNAME,NAME,KNAME 2>/dev/null | awk '{print $1}' | cut -d'=' -f2 | tr -d '"')

  # exclude unsupported types
  type_match=$(echo "$type" | grep -E -c -i "disk|ssd|crypt|mpath|part|linear")
  [[ $type_match -ne 1 ]] && continue

  if [[ $type == "disk" ]]
  then
    # exclude parent disk
    children=$(lsblk --noheadings --pairs "$dev_name" 2>/dev/null | wc -l)
    [[ $children -ne 1 ]] && continue
  fi

  #[[ $type == "lvm" ]] && [[ "$dev" =~ "dm-" ]] && continue

  # exclude too small devices
  [[ $size -lt $FIVE_GB_IN_BYTES ]] && continue
  
  # exlude device with filesystem
  fs=$(udevadm info --query=property "$dev_name" 2>/dev/null | grep "ID_FS_TYPE" | cut -d'=' -f2)
  [[ ! -z $fs ]] && continue

  echo "$dev_name"
done