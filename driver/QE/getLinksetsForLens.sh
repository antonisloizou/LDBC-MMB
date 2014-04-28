#!/bin/bash
TIMEFORMAT='%3R'

if [ -z "$1" -o -z "$2" -o -z "$3" ]
then
	echo "Usage: getLinksetsForLens.sh [lensName] [SPARQL Endpoint URL] [Result Dir]"
	exit 1
fi

QUERY=`sed -e "s,LENS_NAME,$1," -e "/^#/d" queries/getLinksetsForLens.sparql`
{ time curl --data-urlencode "query=$QUERY" "$2" 2>/dev/null ; } 2>> $3/response_times_getLinksetsForLens.txt  
