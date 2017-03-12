#!/bin/sh

run_test() {
	peer="$1"
	db="db/ping_${peer}_db.rrd"

	# create database if needed
	if [ ! -f "$db" ]; then
		rrdtool create "$db" \
			--step 60 \
			DS:pl:GAUGE:600:0:100 \
			DS:rtt:GAUGE:600:0:10000000 \
			RRA:AVERAGE:0.5:1:800 \
			RRA:AVERAGE:0.5:6:800 \
			RRA:AVERAGE:0.5:24:800 \
			RRA:AVERAGE:0.5:288:800 \
			RRA:MAX:0.5:1:800 \
			RRA:MAX:0.5:6:800 \
			RRA:MAX:0.5:24:800 \
			RRA:MAX:0.5:288:800
	fi

	# invoke ping and store result
	result=$(ping -q -n -c 10 -w 30 "$peer" 2>&1)

	# extract values from output
	values=$(echo "$result" | gawk '
        BEGIN {
        	pl=100
        	rtt=0.1
        }
        /packets transmitted/ {
            match($0, /([0-9]+)% packet loss/, matchstr)
            pl=matchstr[1]
        }
        /^rtt/ {
            match($4, /(.*)\/(.*)\/(.*)\/(.*)/, a)
            rtt=a[2]
        }
        END {
        	print pl ":" rtt
        }'
    )

    # save values in rrd
    rrdtool update "$db" --template pl:rtt N:$values
}

# run pings in parallel
while read addr comment; do
	run_test "$addr" &
done < peers.txt

# wait for completion of background tasks
wait

exit 0
