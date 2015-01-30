#!/bin/bash

yesterdays_date=$(date +%Y%m%d -d "yesterday")
passeringer_file="_passeringer.csv"
reiser_file="_reiser.csv"
passeringer=$yesterdays_date$passeringer_file
reiser=$yesterdays_date$reiser_file
passeringer_url="ftp://vegvesen:WShTMJRxzL@sinteftfgoofy.sintef.no/$passeringer"
reiser_url="ftp://vegvesen:WShTMJRxzL@sinteftfgoofy.sintef.no/$reiser"
wget $reiser_url
wget $passeringer_url

Rscript R/deriveTravelTimesFromPointRegistrations.R $passeringer
Rscript R/delstrekningParser.R $reiser



