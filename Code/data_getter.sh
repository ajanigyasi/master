#!/bin/bash

yesterdays_date=$(date +%Y%m%d -d "yesterday")
passeringer_file="_passeringer.csv"
reiser_file="_reiser.csv"
passeringer=$yesterdays_date$passeringer_file
reiser=$yesterdays_date$reiser_file
passeringer_url="ftp://vegvesen:WShTMJRxzL@sinteftfgoofy.sintef.no/$passeringer"
reiser_url="ftp://vegvesen:WShTMJRxzL@sinteftfgoofy.sintef.no/$reiser"
wget -P ../Data $reiser_url
wget -P ../Data  $passeringer_url

Rscript R/delstrekningParser.R ../Data/$reiser
Rscript R/deriveTravelTimesFromPointRegistrations.R ../Data/$passeringer



