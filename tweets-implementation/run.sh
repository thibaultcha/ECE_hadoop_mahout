#!/bin/bash

WORK_DIR=/user/root/tweets-implementation
algorithm=(naivebayes classify clean)

if [ -n "$1" ]; then
  choice=$1
else
  echo "Please select a number to choose the corresponding task to run"
  echo "1. ${algorithm[0]} -- train mahout"
  echo "2. ${algorithm[1]} -- classify a set"
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

	if [ ! -f data/tweets-train.tsv ]; then
	    echo "No training file at data/tweets-train.tsv"
	    exit 1
	fi

	echo "Creating work directory at ${WORK_DIR}"
	if hadoop fs -test -d ${WORK_DIR} ; then
        hadoop fs -rmr ${WORK_DIR}
	fi
	hadoop fs -mkdir ${WORK_DIR}

	echo "Converting tsv to sequence files..."
	java -cp mahout-tweets-classifier-1.0-jar-with-dependencies.jar \
		mahout.classifier.TweetTSVToSeq data/tweets-train.tsv tweets-seq

	echo "Uploading sequence file to HDFS..."
	if hadoop fs -test -d tweets-seq; then
        hadoop fs -rmr tweets-seq
	fi
	hadoop fs -put tweets-seq ${WORK_DIR}/tweets-seq
	rm -rf tweets-seq

	echo "Converting sequence files to vectors..."
	mahout seq2sparse \
		-i ${WORK_DIR}/tweets-seq \
		-o ${WORK_DIR}/tweets-vectors

	echo "Creating training and holdout set with a random 80-20 split of the generated vector dataset"
	mahout split \
		-i ${WORK_DIR}/tweets-vectors/tfidf-vectors \
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
		-ow -o ${WORK_DIR}/tweets-testing -c

	echo "Testing on holdout set"
	mahout testnb \
		-i ${WORK_DIR}/test-vectors \
		-m ${WORK_DIR}/model \
		-l ${WORK_DIR}/labelindex \
		-ow -o ${WORK_DIR}/tweets-testing -c
fi

# Classify
if [ "x$alg" == "xclassify" ]; then

	set -x

	if ! hadoop fs -test -e ${WORK_DIR}/labelindex ; then
        echo "No index on HDFS at path ${WORK_DIR}/labelindex"
        exit 1
	fi
	if ! hadoop fs -test -d ${WORK_DIR}/model ; then
        echo "No model on HDFS at path ${WORK_DIR}/model"
        exit 1
	fi
	if ! hadoop fs -test -d ${WORK_DIR}/tweets-vectors ; then
        echo "No vector on HDFS at path ${WORK_DIR}/tweets-vectors"
        exit 1
	fi
	if [ ! -f data/tweets-to-classify.tsv ]; then
	    echo "No tweets to classify at path data/tweets-to-classify.tsv"
	    exit 1
	fi

	echo "Retrieving index and model from HDFS"
	hadoop fs -get \
	${WORK_DIR}/labelindex \
	labelindex
	
	hadoop fs -get \
	${WORK_DIR}/model \
	model
	
	hadoop fs -get \
	${WORK_DIR}/tweets-vectors/dictionary.file-0 \
	dictionary.file-0

	hadoop fs -getmerge \
	${WORK_DIR}/tweets-vectors/df-count \
	df-count

	#python scripts/twitter_fetcher.py 1 > data/tweets-to-classify.tsv
	
	read -p "Enter result filename (blank for STDOUT): " result
	if [ -n "$result" ]; then
		echo "Classifying tweets..."
		java -cp mahout-tweets-classifier-1.0-jar-with-dependencies.jar \
		mahout.classifier.Classifier model labelindex dictionary.file-0 df-count data/tweets-to-classify.tsv > ${result}
		echo "Result outputed at ${result}"
	else
		echo "Classifying tweets..."
		java -cp mahout-tweets-classifier-1.0-jar-with-dependencies.jar \
		mahout.classifier.Classifier model labelindex dictionary.file-0 df-count data/tweets-to-classify.tsv
	fi

	echo "Cleaning local filesystem"
	rm labelindex
	rm df-count
	rm dictionary.file-0
	rm -rf model
fi
