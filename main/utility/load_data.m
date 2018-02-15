% ----------------------------------------
% LOAD_DATA.m
%
% Load data from previously saved datasets
% ----------------------------------------

% ----------------------------------------
% MAIN & CONSTANTS
% ----------------------------------------

function [spectra, wavelengths, perturbations] = load_data(mode)
    dt_path = 'smart-color-comparator/data/';
    dt_init = 'initial_color_dataset.mat';
    dt_pert = 'perturbation_dataset.mat';
    n_copies = 4;
    
    [spectra, wavelengths] = load_initial_data(dt_path, dt_init);
    
    switch mode
        case 'load'
            perturbations = load_perturbations(dt_path, dt_pert);
        case 'reload'
            perturbations = reload_perturbations(dt_path, dt_pert, spectra, n_copies);
        otherwise
            error('Mode not supported.');
    end
end

% ----------------------------------------
% FUNCTIONS
% ----------------------------------------

% load_initial_data()
%
% The function will load the initial dataset and store it in three
% variable of workspace
%
% spectra       [1225 x 421]
% wavelengths   [421x1]

function [spectra, wavelengths] = load_initial_data(dt_path, dt_init)
    dataset_path = strcat(dt_path, dt_init);
    vars = load(dataset_path, 'spectra', 'wavelengths');

    spectra = vars.spectra;
    wavelengths = vars.wavelengths;
end

% load_perturbations()
%
% The function will load the perturbated dataset and store it in a variable
% of workspace
%
% perturbations  [1225 x 421 x 5]

function [perturbations] = load_perturbations(dt_path, dt_pert)
    dataset_path = strcat(dt_path, dt_pert);    
    vars = load(dataset_path, 'perturbations');
    
    perturbations = vars.perturbations;
end

% reload_perturbation()
%
% The function will re-generate the perturbated dataset, save it into a
% file and load it in the workspace
%
% perturbation  [1232 x 421 x 4]

function [perturbations] = reload_perturbations(dt_path, dt_pert, spectra, n_copies)
    dataset_path = strcat(dt_path, dt_pert);
    perturbations = generate_gw_noise(spectra, n_copies);
    
    save(dataset_path, 'perturbations');
end

