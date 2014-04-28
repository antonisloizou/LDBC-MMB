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
echo -n  'Enter the Lens name: [Default: Pick a lens randomly for each query.]: '
read LENS
if [ -z $LENS ]
then
LENS=0
echo "Picking a lens randomly for each query"
else
echo 'Using Lens: ' $LENS
fi

# Get Limit
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

# Get results dir
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

# Get output file
echo -n  "Enter the output file for the workload [/path/to/file.ext . Default: ../../workloads/QE_`date +%Y%m%d`.txt]: "
read OUT_FILE
if [ -z $OUT_FILE ]
then
OUT_FILE="../../workloads/QE_`date +%Y%m%d`.txt"
while [ -f $OUT_FILE ]
do
echo -n "File $OUT_FILE already exists. Enter a new output file:"
read OUT_FILE
done
echo "Output file: " $OUT_FILE
elif [ -f $OUT_FILE ]
then
echo "File $OUT_FILE already exists. Using default output file."
OUT_FILE="../../workloads/QE_`date +%Y%m%d`.txt"
while [ -f $OUT_FILE ]
do
echo -n "Default output file $OUT_FILE already exists. Enter a new output file:"
read OUT_FILE
done
echo "Output file: " $OUT_FILE
fi

## GENERATE WORKLOAD FILE, LINE BY LINE

# Pick file
# Compound or target
test=`echo "scale=10; `echo $RANDOM` / 32767 <= $TYPE_BIAS" | bc`
if [ $test -gt 0 ]
then
# compound
if [ $COM_FILE -eq 0]
# pick file randomly
NUM_FILES=`find ../../resources/compounds/ -type f -name *.txt | wc -l`
CUR_FILE=`find ../../resources/compounds/ -type f -name *.txt | tail -n `echo $(( $RANDOM % $NUM_FILES + 1))` | head -1`
else
CUR_FILE=$COM_FILE
fi
LINE="C \t"
else
# target
if [ $TAR_FILE -eq 0]
# pick file randomly
NUM_FILES=`find ../../resources/targets/ -type f -name *.txt | wc -l`
CUR_FILE=`find ../../resources/targets/ -type f -name *.txt | tail -n `echo $(( $RANDOM % $NUM_FILES + 1))` | head -1`
else
CUR_FILE=$TAR_FILE
fi
LINE="T \t"
fi
