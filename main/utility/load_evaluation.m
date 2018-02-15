% ----------------------------------------
% LOAD_EVALUATION.m
%
% Load evaluated object or open GUI to tag
% ----------------------------------------

% ----------------------------------------
% MAIN & CONSTANTS
% ----------------------------------------

function [pairs, ratings] = load_evaluation(mode, lab1, lab2, master_list)
    dt_path = 'smart-color-comparator/data/';
    dt_name = 'evaluation.mat';
    
    dt_filename = strcat(dt_path, dt_name);        
    switch mode
        case 'load'
            [pairs, ratings] = load_eval(dt_filename);
        case 'reload'
            similarity_prompt(lab1, lab2, master_list);
        case 'continue'
            similarity_prompt(dt_filename);
        otherwise
            error('Mode not supported.');
    end
end

% ----------------------------------------
% FUNCTIONS
% ----------------------------------------

% load_eval(dt_filename)
%
% The function will load the evaluated data set
%
% pairs         [n x 2]
% ratings       [1 x n]

function [pairs, ratings] = load_eval(dt_filename)
    vars = load(dt_filename, 'pairs', 'ratings');

    pairs = vars.pairs;
    ratings = vars.ratings;
end

