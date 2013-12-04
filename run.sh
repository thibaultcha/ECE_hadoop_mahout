#!/bin/bash

mvn assembly:assembly
java -jar target/hadoop-0.0.1-jar-with-dependencies.jar
