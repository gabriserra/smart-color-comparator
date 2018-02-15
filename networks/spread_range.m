% --------------------------------------------
% SPREAD_RANGE.m
%
% Calculate spread range of a set of data  
% ---------------------------------------------

% ----------------------------------------
% MAIN
% ----------------------------------------

function [LB, UB] = spread_range(input)
    
    % LB is equal to minimum euclidean distance between adj points
    min_dist_adj = sqrt(sum((input(1, :) - input(2, :)).^2));
    for i = 2:1:length(input)-1
        dist_adj = sqrt(sum((input(i, :) - input(i+1, :)).^2));
        if(dist_adj < min_dist_adj)
            min_dist_adj = dist_adj;
        end
    end
    
    % UB is equal to maxmimum distance between two points
    max_dist_points = 0;
    for i = 1:1:length(input)-1
        for j = i+1:1:length(input)                               
             dist_points = sqrt(sum((input(i, :) - input(j, :)).^2));
             if(dist_points > max_dist_points)
                 max_dist_points = dist_points;
             end
        end
    end
    
    LB = min_dist_adj;
    UB = max_dist_points;
end