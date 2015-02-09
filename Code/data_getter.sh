#!/bin/bash

echo $date #output date to log

#change directory to the directory where this script is located
cd ${0%/*} 

#get yesterday's date
yesterdays_date=$(date +%Y%m%d -d "yesterday")

#create filenames
reiser_str="_reiser.csv"
passeringer_str="_passeringer.csv"
reiser_filename=$yesterdays_date$reiser_str
passeringer_filename=$yesterdays_date$passeringer_str

#create urls
url="ftp://vegvesen:WShTMJRxzL@sinteftfgoofy.sintef.no/"
reiser_url=$url$reiser_filename
passeringer_url=$url$passeringer_filename

#get files
wget -P ../Data $reiser_url
#wget -P ../Data  $passeringer_url

#run R-scripts
Rscript R/delstrekningParser.R ../Data/$reiser_filename
#Rscript R/deriveTravelTimesFromPointRegistrations.R ../Data/$passeringer_filename

#delete downloaded files
rm ../Data/$reiser_filename ../Data/$passeringer_filename



