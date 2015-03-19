#!/bin/bash

#change directory to the directory where this script is located
cd ${0%/*}

Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150301_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150302_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150303_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150304_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150305_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150306_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150307_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150308_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150309_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150310_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150311_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150312_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150313_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150314_passeringer.csv
Rscript R/deriveTravelTimesFromPointRegistrations.R ../../Data/Autopassdata/Singledatefiles/20150315_passeringer.csv

Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150301_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150302_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150303_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150304_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150305_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150306_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150307_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150308_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150309_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150310_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150311_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150312_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150313_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150314_reiser.csv
Rscript R/delstrekningParser.R ../../Data/Autopassdata/Singledatefiles/20150315_reiser.csv
