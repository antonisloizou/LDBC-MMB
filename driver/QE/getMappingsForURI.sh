#!/bin/bash
TIMEFORMAT='%3R'

if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" -o -z "$5" ]
then
	echo "Usage: getMappingsForURI.sh [inputURI] [lensURI] [SPARQL Endpoint URL] [Result Dir] [Log File]"
	exit 1
fi

LOG_FILE=$5

function log () {
	echo `date` : "$0" : "$1" >> $LOG_FILE
}

GET_LINKSETS_OUT=`./getLinksetsForLens.sh $2 $3 $4 $5`
log "getLinksetsForLens.sh response:"
log "$GET_LINKSETS_OUT"
log "End getLinksetsForLens.sh response."
FROM_CLAUSE=`echo "$GET_LINKSETS_OUT" | sed -n 's,.*<binding name="linkset_graph"><uri>,,p' | sed -e 's,</uri></binding>,,' -e 's,^,FROM <,' -e 's,$,>\\\,' | sort | uniq`
PROP_PATH=`echo "$GET_LINKSETS_OUT" | sed -n 's,.*<binding name="link_pred"><uri>,,p' | sed -e 's,</uri></binding>,,' -e 's,^,<,' -e 's,$,>,' | sort | uniq | sed 's,.*,&|^&,' | tr '\n' '|' | sed -e 's,^,(,' -e 's,|$,)*,'`
log "FROM clause:"
log "$FROM_CLAUSE"
log "End FROM clause."
log "Property Path:" 
log "$PROP_PATH"
log "End Property Path."
echo "$FROM_CLAUSE" > .from_clause.tmp
echo "$PROP_PATH" > .prop_path.tmp
QUERY=`sed -e "s,FROM_CLAUSE,$FROM_CLAUSE
," -e "s,INPUT_URI,$1," -e "s,PROP_PATH,$PROP_PATH," ../../queries/QE/getMappingsForURI.sparql`
log "Get mappings query: "
log "$QUERY"
log "End get mappings query."
{ time curl --data-urlencode "query=$QUERY" "$3" 2>/dev/null ; } 2>> $4/response_times_getMappingsForURI.txt
