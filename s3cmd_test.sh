#!/bin/bash

set -e
set -x 

# prepare
# copy some big files(10MB - 200MB per file) from /var/log/ to /tmp/syslog
# create a .s3cfg under $HOME

function put_ls_delete
(
    tempdir=$1
    s3dir=$2
    downloaddir=$3
    mkdir -p $downloaddir
    s3cmd put --recursive $tempdir "$s3dir"
    s3cmd ls --recursive "$s3dir"
    s3cmd get --recursive --force "$s3dir" "$downloaddir"
    s3cmd del --recursive "$s3dir"
    s3cmd du --recursive "$s3dir"
)

for bucket in $(s3cmd ls | awk '{print $3}')
do
    s3cmd ls $bucket
    s3cmd info $bucket
    tempdir="/tmp/s3/create/$RANDOM/$RANDOM"
    mkdir -p $tempdir
    downloaddir="/tmp/s3/download$tempdir"
    mkdir -p $downloaddir
    while [[ $count -lt 10 ]]
    do
        # create some small files
        fallocate -l $RANDOM "$tempdir/$RANDOM.txt"
        count=$(($count+1))
    done
    s3dir="$bucket$tempdir/"
    ls -lR "/tmp/s3"
    put_ls_delete $tempdir $s3dir $downloaddir
    put_ls_delete /tmp/syslog $s3dir $downloaddir
    ls -lR "/tmp/s3"
    rm -rf "/tmp/s3"
    s3cmd del --recursive "$bucket/tmp"
done
