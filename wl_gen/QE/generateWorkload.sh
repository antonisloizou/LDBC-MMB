#!/bin/bash

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
echo -n  'Enter the source of target URIs [<filename> . Default: Pick a file randomly for each query.]: '
read COM_FILE
if [ -z $COM_FILE ]
then
COM_FILE=0
echo "Picking a file randomly for each query"
elif [ -f $COM_FILE ]
then
echo 'Target URI source: ' $COM_FILE
else 
echo "File not found: $COM_FILE . Picking a file randomly for each query"
fi
echo -n  'Enter the Lens name: [Default: Pick a lens randomly for each query.]: '
read LENS
if [ -z $LENS ]
then
LENS=0
echo "Picking a lens randomly for each query"
else
echo 'Using Lens: ' $LENS
fi
echo -n  'Enter the LIMIT to use: [Positive integer. Default: Pick one of 10, 25, 50.]: '
read LIMIT
if [ -z $LIMIT ]
then
LIMIT=0
echo "Picking LIMIT randomly from [10, 25, 50]."
else
test=`echo "$LIMIT < 0" | bc`
if [ $test -gt 0 -o "$LIMIT" == *.* ]
then
echo "Must be positive. Picking LIMIT randomly from [10, 25, 50]."
elif [[ $LIMIT == *.* ]]
then
echo "Must be an integer. Picking LIMIT randomly from [10, 25, 50]."
else 
echo "Using LIMIT: " $LIMIT
fi
fi
echo -n  "Enter the results directory [/path/to/dir/ . Default: ../../results/QE/`date +%Y%m%d`]: "
read RES_DIR
if [ -z $RES_DIR ]
then
RES_DIR="../../results/QE/`date +%Y%m%d`"
while [ -d $RES_DIR ]
do
echo -n "Directory $RES_DIR already exists. Enter a new results directory:"
read RES_DIR
done
mkdir $RES_DIR
echo "Results directory: " $RES_DIR
elif [ -d $RES_DIR ]
then
echo "Directory $RES_DIR already exists. Using default results directory."
RES_DIR="../../results/QE/`date +%Y%m%d`"
while [ -d $RES_DIR ]
do
echo -n "Default results directory $RES_DIR already exists. Enter a new results directory:"
read RES_DIR
done
mkdir $RES_DIR
echo "Results directory: " $RES_DIR
fi
