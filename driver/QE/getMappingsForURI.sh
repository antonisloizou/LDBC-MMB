#!/bin/bash
TIMEFORMAT='%3R'

if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]
then
	echo "Usage: getMappingsForURI.sh [inputURI] [lensName] [SPARQL Endpoint URL] [Result Dir]"
	exit 1
fi

GET_LINKSETS_OUT=`./getLinksetsForLens.sh $2 $3 $4`
FROM_CLAUSE=`echo "$GET_LINKSETS_OUT" | sed -n 's,.*<binding name="linkset_graph"><uri>,,p' | sed -e 's,</uri></binding>,,' -e 's,^,FROM <,' -e 's,$,>,' | sort | uniq`
#echo "$FROM_CLAUSE"
PROP_PATH=`echo "$GET_LINKSETS_OUT" | sed -n 's,.*<binding name="link_pred"><uri>,,p' | sed -e 's,</uri></binding>,,' -e 's,^,<,' -e 's,$,>,' | sort | uniq | sed 's,.*,&|^&,' | tr '\n' '|' | sed -e 's,^,(,' -e 's,|$,)+,'`
echo "$PROP_PATH"

#QUERY=`sed -e "s,LENS_NAME,$1," -e "/^#/d" queries/getLinksetsForLens.sparql`
#{ time curl --data-urlencode "query=$QUERY" "$2" ; } 2>> $3/response_times_getLinksetsForLens.txt  
