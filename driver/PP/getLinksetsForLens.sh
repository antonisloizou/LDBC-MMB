#!/bin/bash
TIMEFORMAT='%3R'

if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]
then
	echo "Usage: getLinksetsForLens.sh [lensURI] [SPARQL Endpoint URL] [Result Dir] [Log File]"
	exit 1
fi

LOG_FILE=$4

function log () {
        echo `date` : "$0" : "$1" >> $LOG_FILE
}

QUERY=`sed -e "s,LENS_URI,$1," -e "/^#/d" ../../queries/QE/getLinksetsForLens.sparql`
log "Query: "
log "$QUERY"
log "End query."
{ time curl --data-urlencode "query=$QUERY" "$2" 2>/dev/null ; } 2>> $3/response_times_getLinksetsForLens.txt  
