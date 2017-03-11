#!/bin/sh

index_header=$(cat <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Round-Trip &amp; Packetloss Stats</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="header-box">
	<div class="header-text"><span class="header-text-pri"><a href="index.html">Round-Trip &amp; Packetloss Stats</a></span></div>
</div>

<div class="content-box">
EOF
)

index_footer=$(cat <<EOF
</div>
</body>
</html>
EOF
)

index_host=$(cat <<EOF
<a href="host_[ADDR].html">
<div class="panel-box">
	<div class="panel-heading">
		Host [ADDR]
	</div>
	<div class="panel-content">
		<img src="ping_[ADDR]_day.png">
	</div>
</div>
</a>
EOF
)

host_page=$(cat <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Round-Trip &amp; Packetloss Stats</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<div class="header-box">
	<div class="header-text"><span class="header-text-pri"><a href="index.html">Round-Trip &amp; Packetloss Stats</a></span><span class="header-text-sec">&#x2B62; [ADDR]</span></div>
</div>

<div class="content-box">
	<div class="panel-box">
		<div class="panel-heading">
			Day
		</div>
		<div class="panel-content">
			<img src="ping_[ADDR]_day.png">
		</div>
	</div>

	<div class="panel-box">
		<div class="panel-heading">
			Week
		</div>
		<div class="panel-content">
			<img src="ping_[ADDR]_week.png">
		</div>
	</div>

	<div class="panel-box">
		<div class="panel-heading">
			Month
		</div>
		<div class="panel-content">
			<img src="ping_[ADDR]_month.png">
		</div>
	</div>

	<div class="panel-box">
		<div class="panel-heading">
			Year
		</div>
		<div class="panel-content">
			<img src="ping_[ADDR]_year.png">
		</div>
	</div>
</div>
</body>
</html>
EOF
)


# create index page
echo "$index_header" > "out/index.html"

peers="$(cat peers.txt 2> /dev/null)"
for peer in $peers; do
	echo "$index_host" | sed "s/\[ADDR\]/$peer/g" >> "out/index.html"
done

echo "$index_footer" >> "out/index.html"


# create host pages
peers="$(cat peers.txt 2> /dev/null)"
for peer in $peers; do
	echo "$host_page" | sed "s/\[ADDR\]/$peer/g" >> "out/host_${peer}.html"
done