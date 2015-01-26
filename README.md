# Mahout Classification
Assignment for the **Data Scientist** course at ECE Paris (2013).

The goal is to pull tweets containing the hashtag `#edf` and determine if the tweet is about [Électricité de France](http://france.edf.com/france-45634.html) (French company) or [Équipe de France](http://www.fff.fr/) (France's national soccer team).

This was a real use case for EDF (the company) when they wanted to perform sentiment analysis on Twitter last year.

## Implementations

I made two implementations: `tweets-implementation`, based on an [example](http://chimpler.wordpress.com/2013/03/13/using-the-mahout-naive-bayes-classifier-to-automatically-classify-twitter-messages/) on the Internet that I have adapted to my needs, to test and understand how Mahout works. And one following the guidelines for the assignment in `website-implementation`.

**Both train and test data and can classify a real data set.**

Tested on the Hortonworks sandbox.

## website-implementation

Crawl data from websites, run a map job on it to extract content from HTML through Jsoup and Lucene. Then train and classify with mahout.

### Make it run

- Compile the jar (I uploaded an already compiled jar in case of lazyness)

`mvn assembly:assembly`

- Upload `mahout-website-classifier-1.0-jar-with-dependencies.jar` and the `wget` directory to your machine

- Run the crawler `wget/wget.sh`

- Run the script (after choosing your WORK_DIR)

`./run.sh`

The script allows you to train and test the data. Type 1 and train it.

### Classify real data

- Fetch some data to test

`python twitter_fetcher 10 > tweets-to-classify.tsv`

The script needs the [tweepy](https://github.com/tweepy/tweepy) module. But I have provided a file in `/scripts` already.

- Make sure you have `tweets-to-classify.tsv` on your machine and that you have already trained mahout

- Run the script

`./run.sh`

From there tell the script you want to classify real data (2)

## tweets-implementation

Fetch tweets with a Python script. Provide a file with some manually classified tweets to create the vectors (I did this already on ~60 tweets, not enough but it's boring). Then create vectors from that file, and train and test Mahout on it. It can even test a real data set to classify it.

### Make it run

- Compile the jar (already compile in case)

`mvn assembly:assembly`

- Make sure you have a `data/tweets-train.tsv` file (provided in the repo)

- Upload `mahout-tweets-classifier-1.0-jar-with-dependencies.jar` and the `data` directory to your machine

- Run the script (after choosing your WORK_DIR)

`./run.sh`

The script ask you if you want to train mahout or test real data, first train mahout (2)

### Classify real data

- Fetch some data to test

`python twitter_fetcher 10 > tweets-to-classify.tsv`

The script needs the [tweepy](https://github.com/tweepy/tweepy) module. But I have provided a file in `data/` already.

- Make sure you have `data/tweets-to-classify.tsv` on your machine and that you have already trained mahout

- Run the script

`./run.sh`

From there tell the script you want to classify real data (2)
