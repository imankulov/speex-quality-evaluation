#!/bin/bash
# dbov - db level relative to overload. -4dBov (0.6309) should enought to avoid clipping
tmp=$(tempfile -s.wav)
trap "rm -f $tmp" EXIT SIGINT SIGQUIT SIGTERM
src=$1
dst=$2

# find adjustment level (respecting clipping elimination)
maxvol=$(sox $1 $tmp stat -v 2>&1)
vol=$(bc -l <<<"$maxvol*0.6309")

# adjust and apply lowpass filter
sox -v $vol  $src $tmp lowpass 4000
# resample and add leading and trailing silence (0.5 s)
sox $tmp -r8000 $dst pad 0.5 0.5
