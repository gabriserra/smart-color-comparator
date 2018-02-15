% ----------------------------------------
% GENERATE_NOISE.m
%
% Generate a random gaussian white noise 
% and add it to the spectra signal
% ----------------------------------------

% ----------------------------------------
% MAIN & CONSTANTS
% ----------------------------------------

function perturbations = generate_gw_noise(spectra, n_copies) 
    
    n_copies_default = 4;
    
    if(nargin < 2)
        n_copies = n_copies_default;
    end

    perturbations = generate_noise(spectra, n_copies);
    
end

% ----------------------------------------
% FUNCTIONS
% ----------------------------------------

% generate_noise(spectra, n_copies)
%
% The function will generate perturbated copies of original signal.
% For each patch, n_copies are generated.
%
% perturbations [1232 x 421 x 4]

function perturbations = generate_noise(spectra, n_copies)

    [n_patches, n_wavelenths] = size(spectra);
    perturbations = zeros(n_patches, n_wavelenths, n_copies);
    
    for i = 1 : n_patches
        for current_copy = 1 : n_copies
            db = 63.97 * exp(-0.3284 * current_copy);
            
            rng(1);
            perturbated_signal = awgn(spectra(i, :), db);
            perturbated_signal(perturbated_signal<0) = 0;
            perturbations(i, :, current_copy) = perturbated_signal;
        end
    end
end