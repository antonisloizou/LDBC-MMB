#/bin/bash
if [ -z $1 -o -z $2 ]
then 
	echo "Usage ./generateTSV.sh [Workload File] [Results Dir]"
	exit 1
fi

HEADER="# C/T	URI	Lens	Limit"
for file in `ls $2/response_times_*`
do
	HEADER="$HEADER	`basename $file .txt`"
done

HEADER="$HEADER	triple_count_pharmacology"

echo -e "$HEADER"
paste <(grep -v ^# $1) $2/response_times_* $2/triple_count_pharmacology.txt
