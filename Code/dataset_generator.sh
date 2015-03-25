#!/bin/bash

#change directory to the directory where this script is located
cd ${0%/*}

Rscript R/createDataSet.R 20150315 2015 03 16
Rscript R/createDataSet.R 20150316 2015 03 17 
Rscript R/createDataSet.R 20150317 2015 03 18 
Rscript R/createDataSet.R 20150318 2015 03 19 
Rscript R/createDataSet.R 20150319 2015 03 20 
Rscript R/createDataSet.R 20150320 2015 03 21 
Rscript R/createDataSet.R 20150321 2015 03 22 
