#!/bin/bash

#change directory to the directory where this script is located
cd ${0%/*}

#get traffic messages for E18 Oslo
wget  -O ../Data/recent_messages.xml "http://www.vegvesen.no/trafikk/xml/search.xml?searchFocus.counties=3&searchFocus.messageType=17&searchFocus.messageType=19&searchFocus.messageType=20&searchFocus.messageType=18&searchFocus.messageType=38&searchFocus.messageType=22&searchFocus.messageType=23&searchFocus.messageType=21&searchFocus.roadNumber=18&searchFocus.roadTypes=Ev&searchFocus.roadTypes=Rv&searchFocus.sortOrder=3"

#add new messages to the log
python xml_parser.py ../Data/recent_messages.xml

#delete downloaded xml file
rm ../Data/recent_messages.xml
