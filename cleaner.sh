#!/bin/bash

# Daemon fix
my_path="$(dirname $0)"
cd "$my_path"

# Incoming argv count test
if [ $# -lt 3 ]
then
 echo "./cleaner.sh <path> <filemask> <count>"
 exit
fi

# Include libs
source functions.sh

x=1         # For increment
path=$1     # Dir path
filemask=$2 # Filename mask
keep=$3     # Exclude latest {count} files

current=`latest_backup`

ls -t $path/$filemask | grep -v "$current" | \
while read filename
    do
        if [ $x -le $keep ]
            then
                x=$(($x+1))
                continue
        fi
        echo "INF: Remove $filename"
        rm $filename
done
