#!/bin/bash

# -i list of input sources
# each line different website
# http://www.fff.fr
# http://www.lequipe.fr

hadoop fs -rmr /user/root/mahout/crawler/

mkdir -p ./edf; rm -rf ./edf/*;
wget --recursive --mirror -np -A.html -i ./edf.txt -Q100m -P ./edf
#hadoop fs -put ./edf /user/root/mahout/crawler/edf/
#rm -rf edf

mkdir -p ./soccer; rm -rf ./soccer/*;
wget --recursive --mirror -np -A.html -i ./soccer.txt -Q100m -P ./soccer
#hadoop fs -put ./soccer /user/root/mahout/crawler/soccer/
#rm -rf soccer
