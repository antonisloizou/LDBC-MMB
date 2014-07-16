#/bin/bash
if [ -z $1 -o -z $2 ]
then 
	echo "Usage ./generateTSV.sh [Workload File] [Results Dir]"
	exit 1
fi

HEADER="# C/T	URI	Lens	Limit	response_times_getLinksetsForLens	response_times_insert	response_times_pharmacology	response_times_drop	triple_count_pharmacology"

echo -e "$HEADER"
paste <(grep -v ^# $1) $2/response_times_getLinksetsForLens.txt $2/response_times_insert.txt $2/response_times_pharmacology.txt $2/response_times_drop.txt $2/triple_count_pharmacology.txt
