#!/bin/bash

## NOTE: If you change this script please re-upload to: https://access.redhat.com/solutions/544883

## tcpdump-watch.sh

## Simple tool to capture tcpdump (handles multiple IPs / interfaces) until certain log message is matched.

## Fill in each of the variables in the SETUP section then invoke the script and wait
## for the issue to occur, the script will stop on it's own when the $match is seen
## in the $log file.

## Gather various NFS data files as well before the tcpdumps begin and after they end

timeout=""
[ -x /usr/bin/timeout ] && timeout="/usr/bin/timeout 10"

function copy_dir {
	# src dest
	[ ! -z "$timeout" ] && $timeout cp -r "$1" "$2"
}

function copy_nfs_files {
#	$timeout tar -czvf "$1"/proc-fs-nfsd.$2.tgz /proc/fs/nfsd/* >/dev/null 2>&1
#	$timeout tar -czvf "$1"/proc-fs-nfs.$2.tgz /proc/fs/nfs/* >/dev/null 2>&1
#	$timeout tar -czvf "$1"/proc-net-rpc-content.$2.tgz /proc/net/rpc/*/content  >/dev/null 2>&1
	[ -f /proc/self/mountstats ] &&	cp /proc/self/mountstats "$1/proc-self-mountstats.$2" >/dev/null 2>&1
	[ -f /proc/net/rpc/nfsd ] && cp /proc/net/rpc/nfsd "$1/proc-net-rpc-nfsd.$2" >/dev/null 2>&1
	echo "$2 $(date)" >> "$1/date"
	[ -d /sys/kernel/debug/sunrpc ] && copy_dir /sys/kernel/debug/sunrpc "$1/sunrpc.$2"
}

## -------- SETUP ---------

if [ $# -lt 2 ]; then
    echo "Usage: $(basename "$0") caseno nfs-server-ip1 nfs-server-ip2 ... nfs-server-ipN"
    exit 1
fi

caseno=$1

# File output directory
output_dir="/tmp/nfs-data-$caseno-$$"
if [ ! -f "$output_dir" ]; then
	echo "Creating output directory $output_dir"
	mkdir -p "$output_dir"
fi

# Logfile to watch.  Accepts wildcards to watch multiple logfiles at once.
log="/var/log/messages"

# Message to match from log
match="not responding"

# Amount of time in seconds to wait before the tcpdump is stopped following a match
wait="2"

# Minimum runtime, to avoid already in-progress timeouts from stopping the script early
min_runtime="200"

## -------- END SETUP ---------

# Record the timezone of the machine
date +%Z > "$output_dir/tz"

# NOTE: There can be multiple NFS server IPs, but there must be at least one
shift
while [ "$1" ]; do
	nfs_server="$1"
	echo "$nfs_server"
	shift

	# NOTE: We could accept a DNS name but then we'd need to convert to IP
	if [[ $nfs_server =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		echo "Found valid IP address $nfs_server for NFS server"
	else
		echo "Could not validate $nfs_server as an IP of NFS server"
		echo "Please enter a valid IP of NFS server"
		exit 1
	fi

	# Interface to gather tcpdump, derived based on the IP address of the NFS server
	# NOTE: To prevent BZ 972396 we need to specify the interface by interface number
	# Check for local interface first
	ip_device=$(ip -o a | grep "$nfs_server")
	if [ $? -eq 0 ]; then
		device=$(echo "$ip_device" | awk '{ print $2 }')
		echo "Found local device $device for IP $nfs_server"
	else
		device=$(ip route get "$nfs_server" | head -n1 | awk '{print $(NF-2)}')
		echo "Found remote device $device for IP $nfs_server"
	fi
	interface=$(tcpdump -D | grep -e "$device" | colrm 3 | sed 's/\.//')
	echo "Using tcpdump interface $interface for capture"

	tcpdump_output="$output_dir/tcpdump-$nfs_server.pcap"
	tcpdump="tcpdump -s0 -i $interface host $nfs_server -W 4 -C 256M -w $tcpdump_output -Z root"
	echo "$tcpdump"

	$tcpdump &
	tcpdump_pids="$tcpdump_pids $!"
done

# Capture 'begin' of various NFS files as well as $log
echo "Copying various NFS related files to $output_dir with 'begin' suffix"
copy_nfs_files "$output_dir" "begin"

echo "Copying $log to $output_dir/$(basename $log).begin"
cp "$log" "$output_dir/$(basename $log).begin"

start_time=$(date +%s)
end_time=$(($start_time + $min_runtime))
tail --follow=name -n 1 "$log" |
while read line
do
        ret=$(echo "$line" | grep "$match")
        if [[ -n $ret ]]
        then
                if [[ $(date +%s) -lt $end_time ]] ; then
                        continue
                fi
                sleep $wait
                kill $tcpdump_pids
                break 1
        fi
done

echo "Copying various NFS related files to $output_dir with 'end' suffix"
copy_nfs_files "$output_dir" "end"

echo "Copying $log to $output_dir/$(basename $log).end"
cp "$log" "$output_dir/$(basename $log).end"

if [ -e /bin/gzip ]; then
        echo "Gzipping $output_dir/*.pcap"
        gzip -f "$output_dir"/*.pcap*
fi

# Now package up all files into one tarball
tar -czvf "$output_dir.tgz" "$output_dir"/*

echo "Please upload $output_dir.tgz to Red Hat for analysis."
