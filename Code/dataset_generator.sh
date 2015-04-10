#!/bin/bash

#change directory to the directory where this script is located
cd ${0%/*}

Rscript R/createDataSet.R 20150326 2015 03 27
Rscript R/createDataSet.R 20150327 2015 03 28
Rscript R/createDataSet.R 20150328 2015 03 29
Rscript R/createDataSet.R 20150329 2015 03 30
Rscript R/createDataSet.R 20150330 2015 03 31
