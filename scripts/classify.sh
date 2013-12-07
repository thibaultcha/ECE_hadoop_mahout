#!/bin/bash

if [ "$1" = "--help" ] || [ "$1" = "--?" ]; then
  echo "This script runs SGD and Bayes classifiers over the classic 20 News Groups."
  exit
fi

WORK_DIR=/user/root/mahout
algorithm=(naivebayes clean)
if [ -n "$1" ]; then
  choice=$1
else
  echo "Please select a number to choose the corresponding task to run"
  echo "1. ${algorithm[0]}"
  echo "2. ${algorithm[1]} -- cleans up the work area in $WORK_DIR"
  read -p "Enter your choice : " choice
fi

echo "ok. You chose $choice and we'll use ${algorithm[$choice-1]}"
alg=${algorithm[$choice-1]}

if [ "x$alg" != "xclean" ]; then
  echo "creating work directory at ${WORK_DIR}"
  mkdir -p ${WORK_DIR}
fi

set -e

if [ "x$alg" == "xnaivebayes" ]; then
  c=""

  set -x
  echo "Preparing twitter data"
  rm -rf ${WORK_DIR}/tweets-all
  mkdir ${WORK_DIR}/tweets-all
  cp -R ${WORK_DIR}/crawler/*/* ${WORK_DIR}/tweets-all

  # echo "Creating sequence files from twitter data"
  # mahout seqdirectory \
  #   -i ${WORK_DIR}/tweets-all \
  #   -o ${WORK_DIR}/tweets-seq -ow

  # echo "Converting sequence files to vectors"
  # mahout seq2sparse \
  #   -i ${WORK_DIR}/tweets-seq \
  #   -o ${WORK_DIR}/tweets-vectors  -lnorm -nv  -wt tfidf

  # echo "Creating training and holdout set with a random 80-20 split of the generated vector dataset"
  # mahout split \
  #   -i ${WORK_DIR}/tweets-vectors/tfidf-vectors \
  #   --trainingOutput ${WORK_DIR}/tweets-train-vectors \
  #   --testOutput ${WORK_DIR}/tweets-test-vectors  \
  #   --randomSelectionPct 40 --overwrite --sequenceFiles -xm sequential

  # echo "Training Naive Bayes model"
  # mahout trainnb \
  #   -i ${WORK_DIR}/tweets-train-vectors -el \
  #   -o ${WORK_DIR}/model \
  #   -li ${WORK_DIR}/labelindex \
  #   -ow $c

  # echo "Self testing on training set"
  # mahout testnb \
  #   -i ${WORK_DIR}/tweets-train-vectors\
  #   -m ${WORK_DIR}/model \
  #   -l ${WORK_DIR}/labelindex \
  #   -ow -o ${WORK_DIR}/tweets-testing $c

  # echo "Testing on holdout set"
  # mahout testnb \
  #   -i ${WORK_DIR}/tweets-test-vectors\
  #   -m ${WORK_DIR}/model \
  #   -l ${WORK_DIR}/labelindex \
  #   -ow -o ${WORK_DIR}/tweets-testing $c
fi
