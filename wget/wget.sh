#!/bin/bash

# -i list of input sources
# each line different website
# http://www.fff.fr
# http://www.lequipe.fr

mkdir -p ./edf; rm -rf ./edf/*;
wget --recursive --mirror -np -A.html -i ./edf.txt -Q100m -P ./edf
hadoop fs -rmr /user/big/twitter/edf
hadoop fs -put ./edf /user/big/twitter/edf/
rm -rf edf

mkdir -p ./soccer; rm -rf ./soccer/*;
wget --recursive --mirror -np -A.html -i ./soccer.txt -Q100m -P ./soccer
hadoop fs -rmr /user/big/twitter/soccer/
hadoop fs -put ./soccer /user/big/twitter/soccer/
rm -rf soccer
