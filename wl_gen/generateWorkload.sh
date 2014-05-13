#!/bin/bash

## GET AND SANITIZE PARAMETERS

# Get type bias
echo -n  'Enter the ratio of compounds, i.e. P(compound) = 1 - P(target) [Default: 0.5]: '
read TYPE_BIAS
if [ -z $TYPE_BIAS ]
then
	TYPE_BIAS=0.5
fi
test=`echo "$TYPE_BIAS < 0" | bc`
if [ $test -gt 0 ]
then
	echo "Out of bounds"
	TYPE_BIAS=0.5
fi
test=`echo "$TYPE_BIAS > 1" | bc`
if [ $test -gt 0 ]
then
	echo "Out of bounds"
	TYPE_BIAS=0.5
fi
echo 'P(compound) = ' $TYPE_BIAS

# Get primary/secondary URI bias
echo -n  'Enter the ratio of URIs from primary data sources, i.e. P(primary) = 1 - P(secondary) [Default: 0.5]: '
read URI_BIAS
if [ -z $URI_BIAS ]
then
	URI_BIAS=0.5
fi
test=`echo "$URI_BIAS < 0" | bc`
if [ $test -gt 0 ]
then
	echo "Out of bounds"
	URI_BIAS=0.5
fi
test=`echo "$URI_BIAS > 1" | bc`
if [ $test -gt 0 ]
then
	echo "Out of bounds"
	URI_BIAS=0.5
fi
echo 'P(primary) = ' $URI_BIAS

# Get source for compounds
echo -n  'Enter the source of compound URIs [<filename> . Default: Pick a file randomly for each query.]: '
read COM_FILE
if [ -z $COM_FILE ]
then
	COM_FILE=0
	echo "Picking a file randomly for each query"
elif [ -f $COM_FILE ]
then
	echo 'Compound URI source: ' $COM_FILE
else 
	echo "File not found: $COM_FILE . Picking a file randomly for each query"
fi

# Get source for targets
echo -n  'Enter the source of target URIs [<filename> . Default: Pick a file randomly for each query.]: '
read TAR_FILE
if [ -z $TAR_FILE ]
then
	TAR_FILE=0
	echo "Picking a file randomly for each query"
elif [ -f $TAR_FILE ]
then
	echo 'Target URI source: ' $TAR_FILE
else 
	echo "File not found: $TAR_FILE . Picking a file randomly for each query"
fi

# Get Lens
echo -n  'Enter the Lens URI: [Default: Pick a lens randomly for each query.]: '
read LENS
if [ -z $LENS ]
then
	LENS=0
	echo "Picking a lens randomly for each query"
else
	test=0
	for lens in `cat ../resources/lenses/lenses.txt`
	do
		if [ "$LENS" == "$lens" ]
		then
			test=1
		fi
	done
	if [ $test -eq 1 ]
	then
		echo 'Using Lens: ' $LENS
	else
		$LENS=0
		echo "Invalid lens. Picking one randomly for each query"
	fi
fi

# Get Limit
echo -n  'Enter the PAGE_SIZE to use: [Positive integer. Default: Pick one of 10, 25, 50.]: '
read LIMIT
if [ -z $LIMIT ]
then
	LIMIT=0
echo "Picking PAGE_SIZE randomly from [10, 25, 50]."
else
	test=`echo "$LIMIT < 0" | bc`
	if [ $test -gt 0 ]
	then
		echo "Must be positive. Picking PAGE_SIZE randomly from [10, 25, 50]."
		LIMIT=0
	elif [[ $LIMIT == *.* ]]
	then
		echo "Must be an integer. Picking PAGE_SIZE randomly from [10, 25, 50]."
	LIMIT=0
	else 
		echo "Using LIMIT: " $LIMIT
	fi
fi

# Get output file
echo -n  "Enter the output file for the workload [<filename> . Default: ../workloads/wl_`date +%Y%m%d`.txt]: "
read OUT_FILE
if [ -z $OUT_FILE ]
then
	OUT_FILE="../workloads/wl_`date +%Y%m%d`.txt"
	while [ -f $OUT_FILE ]
	do
		echo -n "File $OUT_FILE already exists. Enter a new output file:"
		read OUT_FILE
	done
	echo "Output file: " $OUT_FILE
elif [ -f $OUT_FILE ]
then
	echo "File $OUT_FILE already exists. Using default output file."
	OUT_FILE="../workloads/wl_`date +%Y%m%d`.txt"
	while [ -f $OUT_FILE ]
	do
		echo -n "Default output file $OUT_FILE already exists. Enter a new output file:"
		read OUT_FILE
	done
	echo "Output file: " $OUT_FILE
fi

# Get workload size
echo -n  'Enter the number of queries in the workload: [Positive integer. Default: 10.]: '
read WL_SIZE
if [ -z $WL_SIZE ]
then
	WL_SIZE=10
	echo "Number of queries in workload: " $WL_SIZE
else
	test=`echo "$WL_SIZE < 0" | bc`
	if [ $test -gt 0 ]
	then
		echo "Must be positive. Generating 10 query parameters by default."
		WL_SIZE=10
	elif [[ $WL_SIZE == *.* ]]
	then
		echo "Must be an integer. Generating 10 query parameters by default."
		WL_SIZE=10
	else
		echo "Number of queries in workload: " $WL_SIZE
	fi
fi

## GENERATE WORKLOAD FILE

# Generate headers
echo '# P(compound) = ' $TYPE_BIAS >> $OUT_FILE
echo '# P(primary URI) = ' $URI_BIAS >> $OUT_FILE

if [ $COM_FILE == 0 ]
then
	echo '# Compound URIs selected randomly.' >> $OUT_FILE
else
	echo '# Compound URIs selected randomly from file: '$COM_FILE >> $OUT_FILE
fi
if [ $TAR_FILE == 0 ]
then
	echo '# Target URIs selected randomly.' >> $OUT_FILE
else
	echo '# Target URIs selected randomly from file: '$TAR_FILE >> $OUT_FILE
fi
echo '#' >> $OUT_FILE
echo -e "# C/T\tURI\tLens\tLimit" >> $OUT_FILE
echo '#' >> $OUT_FILE
# Generate queries one by one
for (( i=0; i < $WL_SIZE; i++ ))
do
	# Pick input URI
	#Primary or secondary
	test=`echo "scale=10; $RANDOM / 32767 <= $URI_BIAS" | bc`
        if [ $test -gt 0 ]
        then
		INPUT_SOURCE="primary"
	else
		INPUT_SOURCE="secondary"
	fi
	#Compound or Target
	test=`echo "scale=10; $RANDOM / 32767 <= $TYPE_BIAS" | bc`
	if [ $test -gt 0 ]
	then
		# Compound
		if [ $COM_FILE == 0 ]
		then
			# Pick file randomly
			NUM_FILES=`find ../resources/compounds/$INPUT_SOURCE/ -type f -name *.txt | wc -l`
			CUR_FILE=`find ../resources/compounds/$INPUT_SOURCE/ -type f -name *.txt | tail -n $(( $RANDOM % $NUM_FILES + 1)) | head -1`
		else
			CUR_FILE=$COM_FILE
		fi
		LINE="C	"
	else
		# Target
		if [ $TAR_FILE == 0 ]
		then
			# Pick file randomly
			NUM_FILES=`find ../resources/targets/$INPUT_SOURCE/ -type f -name *.txt | wc -l`
			CUR_FILE=`find ../resources/targets/$INPUT_SOURCE/ -type f -name *.txt | tail -n $(( $RANDOM % $NUM_FILES + 1)) | head -1`
		else
			CUR_FILE=$TAR_FILE
		fi
		LINE="T	"
	fi
	NUM_LINES=`wc -l < $CUR_FILE`
	LINE="$LINE`tail -n  $(( $RANDOM % $NUM_LINES + 1)) $CUR_FILE | head -1`	"
	# Lens
	if [ $LENS == 0 ]
	then
		# Pick lens randomly
		NUM_LINES=`wc -l < ../resources/lenses/lenses.txt`
		LINE="$LINE`tail -n  $(( $RANDOM % $NUM_LINES + 1)) ../resources/lenses/lenses.txt | head -1`	"
	else
		LINE="$LINE$LENS	"
	fi
	# Limit
	if [ $LIMIT -eq 0 ]
	then
		# Pick limit randomly
		LINE="$LINE`echo -e "10\n25\n50" | tail -n $(($RANDOM % 3 + 1)) | head -1`"
	else
		LINE="$LINE$LIMIT"
	fi
	echo "$LINE" >> $OUT_FILE
done
