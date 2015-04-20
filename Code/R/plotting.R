source('dataSetGetter.R')
firstDay = getDataSet('20150129', '20150129', '../../Data/Autopassdata/Singledatefiles/Dataset/raw/', 'dataset')
firstDay$dateAndTime = strptime(firstDay$dateAndTime, format='%Y-%m-%d %H:%M:%S')
plot(firstDay$dateAndTime, firstDay$trafficVolume, type='l', ylab='', xlab='Time of day', main=NULL)
