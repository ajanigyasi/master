function [dataSet] = calculateCensoredObservations(dataSet)
%CALCULATECENSOREDOBSERVATIONS Summary of this function goes here
%   Detailed explanation goes here
[nObs, nFeats] = size(dataSet);
dataSet.endTime = dataSet.dateAndTime + duration(0, 0, dataSet.actualTravelTime);
dataSet.censoredObservation = repmat(0, nObs, 1);

% Do for each row in the data set
for i=1:10
    % Extract current end time
    p = dataSet.endTime(i);
    % Extract current start time
    m = dataSet.dateAndTime(i);
    % Find the rows having m < start time < p
    index = find(dataSet.dateAndTime > m & dataSet.dateAndTime < p);
    if numel(index) > 0
        k = dataSet.dateAndTime(index);
        dataSet.censoredObservation(index) = seconds(p-k);
    end
end
end