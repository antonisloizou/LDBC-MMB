#!/bin/bash
TIMEFORMAT='%3R'

if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]
then
	echo "Usage: runWorkload.sh [Workload File] [SPARQL Endpoint URL] [Result Dir] [Log File]"
	exit 1
fi

if [ -d $3/QE ]
then
        echo "Directory: $3/QE already exits. Will not overwrite, exiting."
        exit 1
else
	mkdir $3/QE
fi

LOG_FILE=$4

function log () {
        echo `date` : "$0" : "$1" >> $LOG_FILE
}

GRAPHS='http://ops.rsc.org
http://www.conceptwiki.org
http://www.ebi.ac.uk/chembl
http://linkedlifedata.com/resource/drugbank'

while read TYPE INPUT LENS LIMIT 
do
	XML=`./getMappingsForURI.sh $INPUT $LENS $2 $3/QE/ $4`
	log "getMappingsForUri.sh response:"
	log "$XML" 
	log "End getMappingsForUri.sh response."
	FROM_CLAUSE=`cat .from_clause.tmp`
	PROP_PATH=`cat .prop_path.tmp`
	if [ "$TYPE" == "C" ]
	then
		QUERY=`sed -e "s,FROM_CLAUSE,$FROM_CLAUSE
," -e "s,PROP_PATH,$PROP_PATH," -e "s,MY_LIMIT,$LIMIT," ../../queries/QE/compoundPharma.sparql`
	elif [ "$TYPE" == "T" ]
	then
		QUERY=`sed -e "s,FROM_CLAUSE,$FROM_CLAUSE
," -e "s,PROP_PATH,$PROP_PATH," -e "s,PAGE_SIZE,$LIMIT," ../../queries/QE/targetPharma.sparql`
	else
		echo "ERROR: Unknown instance type: $TYPE"
		exit
	fi
	for graph in $GRAPHS
	do
		URIS=`echo "$XML" | grep "$graph" -A 1 | sed -n 's,.*<binding name="uri"><uri>\(.*\)</uri></binding>,\1,p'`
		if [ -z "$URIS" ]
		then
			echo 0 >> $3/QE/mappings_count_`echo $graph | sed -e 's,http://,,' -e 's,/,_,g'`
			echo NULL >> $3/QE/mappings_URIs_`echo $graph | sed -e 's,http://,,' -e 's,/,_,g'`
			QUERY=`echo "$QUERY" | sed "s,GRAPH_${graph}_VALUES,'No mappings found',"`
		else
			echo "$URIS" | wc -l >> $3mappings_count_`echo $graph | sed -e 's,http://,,' -e 's,/,_,g'`
			echo `echo "$URIS" | tr '\n' ' '` >> $3mappings_URIs_`echo $graph | sed -e 's,http://,,' -e 's,/,_,g'`
			RDF_URIS=`echo "$URIS" | sed -e 's,^ *,<,' -e 's, *$,>,' | tr '\n' ' '`
			QUERY=`echo "$QUERY" | sed "s,GRAPH_${graph}_VALUES,$RDF_URIS,"`
		fi
	done
	log "CONSTRUCT query:"
	log "$QUERY"
	log "End construct query"
	RDF=$({ time curl --data-urlencode "query=$QUERY" "$2" 2>/dev/null ; } 2>> $3/response_times_pharmacology.txt)
	log "RDF response received"
	log "$RDF"
	log "End RDF response"
	rapper -c -i guess -  base <<< "$RDF" 2>&1 | grep returned | sed 's,.* \([0-9][0-9]*\) .*,\1,' >> $3/triple_count_pharmacology.txt
done < <(grep -v "^#" $1)

rm .*.tmp
