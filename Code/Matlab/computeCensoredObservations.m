function [dataSet] = computeCensoredObservations(dataSet)
%CALCULATECENSOREDOBSERVATIONS Summary of this function goes here
%   Detailed explanation goes here
    [nObs, ~] = size(dataSet);
    dataSet.endTime = dataSet.dateAndTime + duration(0, 0, dataSet.actualTravelTime);
    dataSet.newestCensoredObservation = repmat(-1, nObs, 1);
    dataSet.oldestCensoredObservation = repmat(-1, nObs, 1);
    dataSet.latestAvailableTravelTime = repmat(-1, nObs, 1);

    % Newest Censored observations
    dataSet = sortrows(dataSet, 'endTime');
    % Do for each row in the data set
    for i=1:100
        % Extract current end time
        p = dataSet.endTime(i);
        % Extract current start time
        m = dataSet.dateAndTime(i);
        % Find the rows having m < start time < p
        index = find(dataSet.dateAndTime > m & dataSet.dateAndTime < p);
        % Only keep the rows having an end time greater than p
        index = index(index>i);
        if numel(index) > 0
            k = dataSet.dateAndTime(index);
            dataSet.newestCensoredObservation(index) = seconds(p-k);
        end
    end
    
    % Oldest Censored observations
    dataSet = sortrows(dataSet, 'endTime');
    % Do for each row in the data set
    for i=1:100
        % Extract current end time
        p = dataSet.endTime(i);
        % Extract current start time
        m = dataSet.dateAndTime(i);
        % Find the rows having m < start time < p
        index = find(dataSet.dateAndTime > m & dataSet.dateAndTime < p);
        % Only keep the rows having an end time greater than p
        index = index(index>i);
        if numel(index) > 0
            index = index(dataSet.oldestCensoredObservation(index) == -1);
            k = dataSet.dateAndTime(index);
            dataSet.oldestCensoredObservation(index) = seconds(p-k);
        end
    end
    
    % Latest available travel time
    dataSet = sortrows(dataSet, 'dateAndTime');
    for i=1:100
        % Extract current time
        currentTime = dataSet.dateAndTime(i);
        % Find the rows having end time <= currentTime
        index = find(dataSet.endTime <= currentTime);
        if numel(index) > 0
            % Extract their end times
            endTimes = dataSet.endTime(index);
            % Find the row having the newest realized travel time
            rowWithNewestTravelTime = dataSet(dataSet.endTime == max(endTimes), :);
            % Insert the travel time of the row having the newest realized
            % travel time
            dataSet.latestAvailableTravelTime(i) = rowWithNewestTravelTime.actualTravelTime;
        end
    end
end