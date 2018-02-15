% ----------------------------------------
% LOAD_SOM.m
%
% Load som trained data from previously 
% saved datasets
% ----------------------------------------

% ----------------------------------------
% MAIN & CONSTANTS
% ----------------------------------------

function [som, net] = load_som(mode, dim)
    dt_path = 'smart-color-comparator/data/';
    dt_som = 'soms.mat';
    dt_output = 'output_';
    dt_net = 'net_';
    dt_lab_5 = 'som_lab_5';
    dt_lab_10 = 'som_lab_10';
    dt_lab_15 = 'som_lab_15';
    dt_spectra_5 = 'som_spectra_5';
    dt_spectra_10 = 'som_spectra_10';
    dt_spectra_15 = 'som_spectra_15';
            
    switch mode
        case 'lab'
            if(dim == 5)
                [som, net] = load_som_data(dt_path, dt_som, dt_net, dt_output, dt_lab_5);
            elseif (dim == 10)
                [som, net] = load_som_data(dt_path, dt_som, dt_net, dt_output, dt_lab_10);
            elseif(dim == 15)
                [som, net] = load_som_data(dt_path, dt_som, dt_net, dt_output, dt_lab_15);
            else
                error('SOM not available');
            end
        case 'spectra'
            if(dim == 5)
                [som, net] = load_som_data(dt_path, dt_som, dt_net, dt_output, dt_spectra_5);
            elseif (dim == 10)
                [som, net] = load_som_data(dt_path, dt_som, dt_net, dt_output, dt_spectra_10);
            elseif(dim == 15)
                [som, net] = load_som_data(dt_path, dt_som, dt_net, dt_output, dt_spectra_15);
            else
                error('SOM not available');
            end
        otherwise
            error('Mode not supported.');
    end
end

% ----------------------------------------
% FUNCTIONS
% ----------------------------------------

% load_som_data(dt_path, dt_som, dt_net, dt_output, dt_var)
%
% The function will load the pre-calculated SOM stored in files
%
% som  [? x ?]

function [som, net] = load_som_data(dt_path, dt_som, dt_net, dt_output, dt_var)
    dataset_path = strcat(dt_path, dt_som);
    var_net = strcat(dt_net, dt_var);
    var_out = strcat(dt_output, dt_var);

    vars = load(dataset_path, var_net, var_out);
    
    fns = fieldnames(vars);
    net = vars.(fns{1});
    som = vars.(fns{2});
end



