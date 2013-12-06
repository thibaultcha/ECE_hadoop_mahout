#!/bin/bash

inputedf='/user/big/twitter/edf'
inputsoccer='/user/big/twitter/soccer'
outputedf='/user/root/big-result/edf'
outputsoccer='/user/root/big-result/soccer'

mvn assembly:assembly

scp -P 2222 target/hadoop-0.0.1-jar-with-dependencies.jar root@127.0.0.1:~/exam

ssh root@127.0.0.1 -p 2222 " \
	echo 'Reseting output'; \
	hadoop fs -rmr hdfs://sandbox:8020/$outputedf; \
	hadoop fs -rmr hdfs://sandbox:8020/$outputsoccer; \
	hadoop jar ./exam/hadoop-0.0.1-jar-with-dependencies.jar $inputedf $outputedf; \
	hadoop jar ./exam/hadoop-0.0.1-jar-with-dependencies.jar $inputsoccer $outputsoccer; \
	echo 'Results at hdfs://sandbox:8020/user/big-result ';"
