#!/bin/bash

input='/user/big/twitter/'
output='/user/root/big-result'

mvn assembly:assembly

scp -P 2222 target/hadoop-0.0.1-jar-with-dependencies.jar root@127.0.0.1:~/exam

ssh root@127.0.0.1 -p 2222 " \
	echo 'Reseting hdfs://sandbox:8020/$output'; \
	hadoop fs -rmr hdfs://sandbox:8020/$output; \
	hadoop jar ./exam/hadoop-0.0.1-jar-with-dependencies.jar $input $output; \
	echo 'Results at hdfs://sandbox:8020/$output ';"
