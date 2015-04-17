#!/bin/bash

#change directory to the directory where this script is located
cd ${0%/*}

Rscript baselinePredictionCreator.R
echo "BaselinePredictionCreator.R is done running" | mail -s "RScript done" thomaswolff90@gmail.com
