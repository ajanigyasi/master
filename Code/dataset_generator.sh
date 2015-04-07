#!/bin/bash

#change directory to the directory where this script is located
cd ${0%/*}

Rscript R/createDataSet.R 20150322 2015 03 23
Rscript R/createDataSet.R 20150323 2015 03 24
Rscript R/createDataSet.R 20150324 2015 03 25
Rscript R/createDataSet.R 20150325 2015 03 26
