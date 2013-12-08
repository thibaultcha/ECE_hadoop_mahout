#!/bin/bash

WORK_DIR=/user/root/edf
algorithm=(naivebayes clean)

if [ -n "$1" ]; then
  choice=$1
else
  echo "Please select a number to choose the corresponding task to run"
  echo "1. ${algorithm[0]}"
  echo "2. ${algorithm[1]} -- cleans up the work area in $WORK_DIR"
  read -p "Enter your choice : " choice
fi

alg=${algorithm[$choice-1]}

# Cleaning stuff
if [ "x$alg" != "xclean" ]; then
  	echo "cleaning work directory at ${WORK_DIR}"
 	if hadoop fs -test –d ${WORK_DIR}; then
        hadoop fs -rmr ${WORK_DIR}
	fi
fi

# Training naive bayes
if [ "x$alg" == "xnaivebayes" ]; then

	set -e
	set -x

	if [ ! -f data/tweets-train.tsv ]; then
	    echo "No training file at data/tweets-train.tsv"
	    exit 1
	fi

	echo "Creating work directory at ${WORK_DIR}"
	if hadoop fs -test –d ${WORK_DIR}; then
        hadoop fs -rmr ${WORK_DIR}
	fi
	hadoop fs -mkdir ${WORK_DIR}

	echo "Converting tsv to sequence files..."
	java -cp target/mahout-classifier-1.0-jar-with-dependencies.jar \
		mahout.classifier.TweetTSVToSeq data/tweets-train.tsv tweets-seq;

	echo "Uploading sequence file to HDFS..."
	if hadoop fs -test –d tweets-seq; then
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
		-m ${WORK_DIR}/model -l labelindex \
		-ow -o ${WORK_DIR}/tweets-testing -c
fi





# Classify
# hadoop fs -get labelindex labelindex
# hadoop fs -get model model
# hadoop fs -get tweets-vectors/dictionary.file-0 dictionary.file-0
# hadoop fs -getmerge tweets-vectors/df-count df-count
# python scripts/twitter_fetcher.py 1 > data/tweets-to-classify.tsv
# java -cp target/mahout-classifier-1.0-jar-with-dependencies.jar \
# 	mahout.classifier.Classifier model labelindex dictionary.file-0 df-count data/tweets-to-classify.tsv
