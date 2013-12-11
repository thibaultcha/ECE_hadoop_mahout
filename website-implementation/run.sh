#!/bin/bash

WORK_DIR=/user/root/website-implementation
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
    hadoop jar mahout-website-classifier-1.0-jar-with-dependencies.jar \
    ${WORK_DIR}/crawled/edf \
    ${WORK_DIR}/crawled-all/edf

    echo "Extracting the shit out of the soccer crawled data..."
    hadoop jar mahout-website-classifier-1.0-jar-with-dependencies.jar \
    ${WORK_DIR}/crawled/soccer \
    ${WORK_DIR}/crawled-all/soccer

    # method 1
    echo "Converting data to sequence files..."
    mahout seqdirectory \
    -i ${WORK_DIR}/crawled-all \
    -o ${WORK_DIR}/crawled-seq -ow -c

    # method 2
    # echo "Fetching parsed data"
    # hadoop fs -get ${WORK_DIR}/crawled-all/ .

    # echo "Converting parsed data to sequence file"
    # java -cp mahout-website-classifier-1.0-jar-with-dependencies.jar \
    #   mahout.classifier.WordsToSeq crawled-all/edf/part-00000 crawled-all/soccer/part-00000 crawled-seq

    # echo "Uploading sequence file to HDFS"
    # hadoop fs -put crawled-seq ${WORK_DIR}
    # rm -rf crawled-seq
    # rm -rf crawled-all

    # then
    echo "Converting sequence files to vectors..."
    mahout seq2sparse \
        -i ${WORK_DIR}/crawled-seq \
        -o ${WORK_DIR}/crawled-vectors  -lnorm -nv  -wt tfidf

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

    if ! hadoop fs -test -e ${WORK_DIR}/labelindex ; then
        echo "No index on HDFS at path ${WORK_DIR}/labelindex"
        exit 1
    fi
    if ! hadoop fs -test -d ${WORK_DIR}/model ; then
        echo "No model on HDFS at path ${WORK_DIR}/model"
        exit 1
    fi
    if ! hadoop fs -test -d ${WORK_DIR}/crawled-vectors ; then
        echo "No vector on HDFS at path ${WORK_DIR}/tweets-vectors"
        exit 1
    fi
    if [ ! -f tweets-to-classify.tsv ]; then
        echo "No tweets to classify at path ./tweets-to-classify.tsv"
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
    ${WORK_DIR}/crawled-vectors/dictionary.file-0 \
    dictionary.file-0

    hadoop fs -getmerge \
    ${WORK_DIR}/crawled-vectors/df-count \
    df-count

    #python scripts/twitter_fetcher.py 1 > data/tweets-to-classify.tsv
    
    read -p "Enter result filename (blank for STDOUT): " result
    if [ -n "$result" ]; then
        echo "Classifying tweets..."
        java -cp mahout-website-classifier-1.0-jar-with-dependencies.jar \
        mahout.classifier.Classifier model labelindex dictionary.file-0 df-count tweets-to-classify.tsv > ${result}
        echo "Result outputed at ${result}"
    else
        echo "Classifying tweets..."
        java -cp mahout-website-classifier-1.0-jar-with-dependencies.jar \
        mahout.classifier.Classifier model labelindex dictionary.file-0 df-count tweets-to-classify.tsv
    fi

    echo "Cleaning local filesystem"
    rm labelindex
    rm df-count
    rm dictionary.file-0
    rm -rf model
fi

