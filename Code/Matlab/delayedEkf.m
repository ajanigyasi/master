function [theta, y_hat] = delayedEkf(x, y, useForTrainingIndex, nh, ns, P, Q, R, theta)
%DELAYEDEKF Perform the delayed EKF method on dataset [x, y]
%   Detailed explanation goes here
    [nx, nObs] = size(x);
    
    % Initialize vector to hold predictions
    y_hat = y;
    
    % Initialize waitbar
    h = waitbar(0,'Performing delayed EKF...');
    
    for k=1:nObs
        waitbar(k/nObs)
        if useForTrainingIndex(k)
            [theta,P,~]=nnekf(theta,P,x(:,k),y(k),Q,R);
        else
            y_hat(k) = nn(theta,x(:, k),size(y(k), 1));
        end
    end
    
    % Close waitbar
    close(h) 
end

