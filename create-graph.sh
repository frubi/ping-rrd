#!/bin/bash

windows="day:86400:60 week:604800:1800 month:2592000:7200 year:31536000:86400"

peers="$(cat peers.txt 2> /dev/null)"
for peer in $peers; do
	db="db/ping_${peer}_db.rrd"
	if [ ! -f "$db" ]; then
		continue
	fi

	for window in $windows; do
		name=$(echo "$window" | cut -d: -f1)
		start=$(echo "$window" | cut -d: -f2)
		end=$(echo "$window" | cut -d: -f3)

		output="out/ping_${peer}_${name}.png"

		rrdtool graph "$output" -h 225 -w 600 -a PNG \
			--lazy --start -$start --end -$end \
			-v "Round-Trip Time (ms)" \
			--rigid \
			--lower-limit 0 \
			DEF:roundtrip="$db":rtt:AVERAGE \
			DEF:packetloss="$db":pl:AVERAGE \
			CDEF:PLNone=packetloss,0,2,LIMIT,UN,UNKN,INF,IF \
			CDEF:PL2=packetloss,2,8,LIMIT,UN,UNKN,INF,IF \
			CDEF:PL15=packetloss,8,15,LIMIT,UN,UNKN,INF,IF \
			CDEF:PL25=packetloss,15,25,LIMIT,UN,UNKN,INF,IF \
			CDEF:PL50=packetloss,25,50,LIMIT,UN,UNKN,INF,IF \
			CDEF:PL75=packetloss,50,75,LIMIT,UN,UNKN,INF,IF \
			CDEF:PL100=packetloss,75,100,LIMIT,UN,UNKN,INF,IF \
			AREA:roundtrip#4444ff:"Round Trip Time (millis)" \
			GPRINT:roundtrip:LAST:"Cur\: %5.2lf" \
			GPRINT:roundtrip:AVERAGE:"Avg\: %5.2lf" \
			GPRINT:roundtrip:MAX:"Max\: %5.2lf" \
			GPRINT:roundtrip:MIN:"Min\: %5.2lf\n" \
			AREA:PLNone#6c9bcd:"0-2%":STACK \
			AREA:PL2#00ffae:"2-8%":STACK \
			AREA:PL15#ccff00:"8-15%":STACK \
			AREA:PL25#ffff00:"15-25%":STACK \
			AREA:PL50#ffcc66:"25-50%":STACK \
			AREA:PL75#ff9900:"50-75%":STACK \
			AREA:PL100#ff0000:"75-100%":STACK \
			COMMENT:"(Packet Loss Percentage)"
	done
done

exit 0
