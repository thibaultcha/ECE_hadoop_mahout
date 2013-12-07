#!/bin/bash

input="/user/root/mahout/crawler"
output="/user/root/mahout/training"

set -x

mvn assembly:assembly

scp -P 2222 target/hadoop-0.0.1-jar-with-dependencies.jar root@127.0.0.1:~/exam

ssh root@127.0.0.1 -p 2222 " \
	echo Reseting hdfs://sandbox:8020$output; \
	hadoop fs -rmr $output/*; \
	hadoop fs -mkdir $output; \
	hadoop jar ./exam/hadoop-0.0.1-jar-with-dependencies.jar $input/edf $output/edf; \
	hadoop jar ./exam/hadoop-0.0.1-jar-with-dependencies.jar $input/soccer $output/soccer; \
	echo Results at hdfs://sandbox:8020/$output;"
