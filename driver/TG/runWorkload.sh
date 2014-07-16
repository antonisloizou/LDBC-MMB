#!/bin/bash
TIMEFORMAT='%3R'

if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]
then
	echo "Usage: runWorkload.sh [Workload File] [SPARQL Endpoint URL] [Result Dir] [Log File]"
	exit 1
fi

if [ -d $3/TG ]
then
        echo "Directory: $3/TG already exits. Will not overwrite, exiting."
        exit 1
else
	mkdir $3/TG
fi

LOG_FILE=$4

function log () {
        echo `date` : "$0" : "$1" >> $LOG_FILE
}

while read TYPE INPUT LENS LIMIT 
do
	GET_LINKSETS_OUT=`./getLinksetsForLens.sh $LENS $2 $3/TG/ $4`
	log "getLinksetsForLens.sh response:"
	log "$GET_LINKSETS_OUT"
	log "End getLinksetsForLens.sh response."
	USING_CLAUSE=`echo "$GET_LINKSETS_OUT" | sed -n 's,.*<binding name="linkset_graph"><uri>,,p' | sed -e 's,</uri></binding>,,' -e 's,^,USING <,' -e 's,$,>\\\,' | sort | uniq`
	FROM_CLAUSE=`echo "$GET_LINKSETS_OUT" | sed -n 's,.*<binding name="linkset_graph"><uri>,,p' | sed -e 's,</uri></binding>,,' -e 's,^,FROM <,' -e 's,$,>\\\,' | sort | uniq`
	PROP_PATH=`echo "$GET_LINKSETS_OUT" | sed -n 's,.*<binding name="link_pred"><uri>,,p' | sed -e 's,</uri></binding>,,' -e 's,^,<,' -e 's,$,>,' | sort | uniq | sed 's,.*,&|^&,' | tr '\n' '|' | sed -e 's,^,(,' -e 's,|$,)*,'`
	log "USING clause:"
	log "$USING_CLAUSE"
	log "End USING clause."
	log "Property Path:"
	log "$PROP_PATH"
	log "End Property Path."
	QUERY=`sed -e "s,USING_CLAUSE,$USING_CLAUSE
," -e "s,PROP_PATH,$PROP_PATH," -e "s,INPUT_URI,$INPUT," ../../queries/TG/insertMappings.sparql`
        log "INSERT query:"
        log "$QUERY"
        log "End INSERT query"
	INSERT_OUT=$({ time curl --data-urlencode "query=$QUERY" "$2" 2>/dev/null ; } 2>> $3/TG/response_times_insert.txt)
	log "INSERT query output:"
	log "$INSERT_OUT"
	log "End INSERT query output"
	if [ "$TYPE" == "C" ]
	then
		QUERY=`sed -e "s,PAGE_SIZE,$LIMIT," -e "s,INPUT_URI,$INPUT," ../../queries/TG/compoundPharma.sparql`
	elif [ "$TYPE" == "T" ]
	then
		QUERY=`sed -e "s,FROM_CLAUSE,$FROM_CLAUSE
," -e "s,PROP_PATH,$PROP_PATH," -e "s,PAGE_SIZE,$LIMIT," -e "s,INPUT_URI,$INPUT," ../../queries/TG/targetPharma.sparql`
	else
		echo "ERROR: Unknown instance type: $TYPE"
		exit
	fi
	log "CONSTRUCT query:"
	log "$QUERY"
	log "End CONSTRUCT query"
	RDF=$({ time curl --data-urlencode "query=$QUERY" "$2" 2>/dev/null ; } 2>> $3/TG/response_times_pharmacology.txt)
	log "RDF response received"
	log "$RDF"
	log "End RDF response"
	rapper -c -i guess -  base <<< "$RDF" 2>&1 | grep returned | sed 's,.* \([0-9][0-9]*\) .*,\1,' >> $3/TG/triple_count_pharmacology.txt
	QUERY=`cat ../../queries/TG/dropTempGraph.sparql`
	log "DROP query:"
	log "$QUERY"
	log "End DROP query"
	DROP_OUT=$({ time curl --data-urlencode "query=$QUERY" "$2" 2>/dev/null ; } 2>> $3/TG/response_times_drop.txt)
	log "DROP query output:"
	log "$DROP_OUT"
	log "End DROP query output"
done < <(grep -v "^#" $1)

rm .*.tmp
