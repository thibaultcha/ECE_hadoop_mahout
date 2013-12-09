#!/bin/bash

WORK_DIR=/user/root/website-implementation
algorithm=(naivebayes classify clean)

if [ -n "$1" ]; then
  choice=$1
else
  echo "Please select a number to choose the corresponding task to run"
  echo "1. ${algorithm[0]} -- train mahout"
  #echo "2. ${algorithm[1]} -- classify a set"
  echo "3. ${algorithm[2]} -- cleans up the work area in $WORK_DIR"
  read -p "Enter your choice : " choice
fi

alg=${algorithm[$choice-1]}

# Cleaning stuff
if [ "x$alg" == "xclean" ]; then
  	echo "Cleaning work directory at ${WORK_DIR}"
 	if hadoop fs -test -d ${WORK_DIR} ; then
        hadoop fs -rmr ${WORK_DIR}
	fi
fi

set -e

# Training naive bayes
if [ "x$alg" == "xnaivebayes" ]; then
	
	set -x

	if [ ! -d wget/soccer ]; then
		echo "No crawled data for soccer at wget/soccer"
		exit 1
	fi
	if [ ! -d wget/edf ]; then
		echo "No crawled data for edf at wget/edf"
		exit 1
	fi

	echo "Creating work directory at ${WORK_DIR}"
	if hadoop fs -test -d ${WORK_DIR} ; then
        hadoop fs -rmr ${WORK_DIR}
	fi
	hadoop fs -mkdir ${WORK_DIR}

	echo "Uploading crawled data to HDFS..."
	if hadoop fs -test -d crawled; then
        hadoop fs -rmr crawled
	fi
	hadoop fs -put wget/soccer ${WORK_DIR}/crawled/soccer
	hadoop fs -put wget/edf ${WORK_DIR}/crawled/edf

	hadoop fs -mkdir ${WORK_DIR}/crawled-all

	echo "Extracting the shit out of the edf crawled data..."
	hadoop jar mahout-classifier-1.0-jar-with-dependencies.jar \
	${WORK_DIR}/crawled/edf \
	${WORK_DIR}/crawled-all/edf

	echo "Extracting the shit out of the soccer crawled data..."
	hadoop jar mahout-classifier-1.0-jar-with-dependencies.jar \
	${WORK_DIR}/crawled/soccer \
	${WORK_DIR}/crawled-all/soccer

	echo "Converting data to sequence files..."
	mahout seqdirectory \
	-i ${WORK_DIR}/crawled-all \
	-o ${WORK_DIR}/crawled-seq -ow

	echo "Converting sequence files to vectors..."
	mahout seq2sparse \
		-i ${WORK_DIR}/crawled-seq \
		-o ${WORK_DIR}/crawled-vectors

	echo "Creating training and holdout set with a random 80-20 split of the generated vector dataset"
	mahout split \
		-i ${WORK_DIR}/crawled-vectors/tfidf-vectors \
		--trainingOutput ${WORK_DIR}/train-vectors \
		--testOutput ${WORK_DIR}/test-vectors \
		--randomSelectionPct 40 --overwrite --sequenceFiles -xm sequential

	echo "Training Naive Bayes model"
	mahout trainnb \
		-i ${WORK_DIR}/train-vectors -el \
		-li ${WORK_DIR}/labelindex \
		-o ${WORK_DIR}/model \
		-ow -c

	echo "Self testing on training set"
	mahout testnb \
		-i ${WORK_DIR}/train-vectors \
		-m ${WORK_DIR}/model \
		-l ${WORK_DIR}/labelindex \
		-ow -o ${WORK_DIR}/crawled-testing -c

	echo "Testing on holdout set"
	mahout testnb \
		-i ${WORK_DIR}/test-vectors \
		-m ${WORK_DIR}/model \
		-l ${WORK_DIR}/labelindex \
		-ow -o ${WORK_DIR}/crawled-testing -c
fi

# Classify
if [ "x$alg" == "xclassify" ]; then

	set -x

fi
