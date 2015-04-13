function [delayedDataSet] = generateDelayedDataSet(predictionDataSet)
%GENERATEDELAYEDDATASET Summary of this function goes here
%   Detailed explanation goes here
    [nObs, ~] = size(predictionDataSet);
    predictionDataSet.endTime = predictionDataSet.dateAndTime + duration(0, 0, predictionDataSet.actualTravelTime);
    predictionDataSet.useForTraining = zeros(nObs, 1);
    
    trainingDataSet = predictionDataSet;
    trainingDataSet.useForTraining = ones(nObs, 1);
    trainingDataSet.dateAndTime = trainingDataSet.endTime;
    
    delayedDataSet = [predictionDataSet; trainingDataSet];
    delayedDataSet = sortrows(delayedDataSet, 'dateAndTime');
end

