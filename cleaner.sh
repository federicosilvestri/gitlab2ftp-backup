#!/bin/bash

# Daemon fix
my_path="$(dirname $0)"
cd "$my_path"

x=1         # For increment
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
