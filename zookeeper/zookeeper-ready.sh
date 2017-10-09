OK=$(echo ruok | nc 127.0.0.1 $1)
if [ "$OK" == "imok" ]; then
	exit 0
else
	exit 1
fi