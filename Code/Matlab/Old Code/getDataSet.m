function [dataSet] = getDataSet(startDate, endDate, directory, model)
%GETDATASET Retrieves data sets within the given range of dates
%   Detailed explanation goes here

% Convert date strings to datetime objects
dateFormatString = 'yyyyMMdd';
startDate = datetime(startDate, 'InputFormat', dateFormatString);
endDate = datetime(endDate, 'InputFormat', dateFormatString); 

% List of all filenames in directory
filenames = ls(directory);
filenames(1:2, :) = [];
filenames = cellstr(filenames);

% Reduce filename to the ones containing model
filenames = filenames(~cellfun('isempty',strfind(filenames,model)));

% Get dates from filenames
dates = datetime(cellfun(@(x) x(1:8), filenames, 'UniformOutput', false), 'InputFormat', dateFormatString);

% Filenames within the provided range of dates
index = (dates >= startDate) & (dates <= endDate);
filenames = filenames(index);
[nofFiles, ~] = size(filenames);

% Read files and generate one data set
formatSpec = '%{yyyy-MM-dd HH:mm:ss}D%f%f%f';
dataSet = readtable(strcat(directory, filenames{1}), 'Delimiter', ';', 'Format', formatSpec);

for i = 2:nofFiles
    tempDataSet = readtable(strcat(directory, filenames{i}), 'Delimiter', ';', 'Format', formatSpec);
    dataSet = vertcat(dataSet, tempDataSet);
end
end

