function [] = saveDataSet(dataSet, directory, filename)
%SAVEDATASET Saves data set to directory
%   dataSet is a table with data
%   directory is the folder which dataSet is to be saved in
%   filename is the filename of the saved file

    firstDate = dataSet.dateAndTime(1);
    lastDate = dataSet.dateAndTime(size(dataSet, 1));
    dates = firstDate:lastDate;

    for i=1:size(dates,2)
        date = yyyymmdd(dates(i));
        writetable(dataSet(yyyymmdd(dataSet.dateAndTime) == date, :), strcat(directory, num2str(date), filename), 'Delimiter', ';');    
    end
end

