function [] = saveDataSet(dataSet, directory, filename)
%SAVEDATASET Saves data set to directory
%   dataSet is a table with data
%   directory is the folder which dataSet is to be saved in
%   filename is the filename of the saved file
writetable(dataSet, strcat(directory, filename), 'Delimiter', ';');
end

