% ----------------------------------------
% CONVERT_COLOR.m
%
% Contains some useful functions to convert
% color from spectra to different spaces
% ----------------------------------------

% ----------------------------------------
% MAIN & CONSTANTS
% ----------------------------------------

function [spectra_rspd, perturbations_rspd, xyz, rgb, lab, p_xyz, p_rgb, p_lab, valid_rgb] = ...
            convert_lib(spectra, perturbations)
    
    global d65 x_fun y_fun z_fun k_norm;
    
    if isempty(d65) % || isempty(x_fun) || isempty(..)
        [d65, x_fun, y_fun, z_fun, k_norm] = init();
    end
    
    
    [xyz, rgb, lab] = spectra2color(spectra);
    [p_xyz, p_rgb, p_lab] = spectra_perturb2color(perturbations);
    valid_rgb = compute_valid_rgb(p_rgb);
    [spectra_rspd, perturbations_rspd] = convert2rspd(spectra, perturbations, 'reload');
end

% ----------------------------------------
% FUNCTIONS
% ----------------------------------------

function [d65, x_fun, y_fun, z_fun, k_norm] = init()

    % Initializing the illuminant
    [~, d65] = illuminant('D65');

    % Initializing the three color matching functions
    [~, x_fun, y_fun, z_fun] = color_matching_functions('1931_FULL');

    % Calculating the normalization factor
    k_norm = y_fun * d65;

    % Results are all row vectors
    d65 = d65.';
    
end

function [xyz, rgb, lab] = spectra2color(spectra)
    global d65 x_fun y_fun z_fun k_norm;

    spectra = spectra';
    [~, n] = size(spectra);

    xyz = zeros(3,n);
    xyz(1, :) = (x_fun .* d65) * spectra;
    xyz(2, :) = (y_fun .* d65) * spectra;
    xyz(3, :) = (z_fun .* d65) * spectra;
    xyz = xyz / k_norm;
    xyz = xyz';

    lab = xyz2lab(xyz);
    rgb = xyz2rgb(xyz);
end

function [xyz, rgb, lab] = spectra_perturb2color(perturbations)

    [m, ~, o] = size(perturbations);
    xyz = zeros(m, 3, o);
    rgb = zeros(m, 3, o);
    lab = zeros(m, 3, o);
    
    for i = 1:o
        [xyz(:,:,i), rgb(:,:,i), lab(:,:,i)] = ...
            spectra2color(perturbations(:, :, i));
    end
end

function [spectra_rspd, perturbations_rspd] = convert2rspd(spectra, perturbations, mode)
    switch mode
        case 'load'
            vars = load('smart-color-comparator/data/rspds.mat', 'spectra_rspd', 'perturbations_rspd');
            spectra_rspd = vars.spectra_rspd;
            perturbations_rspd = vars.perturbations_rspd;
        case 'reload'
            spectra_rspd = spectra2rspd(spectra);
            perturbations_rspd = perturbation2rspd(perturbations);
    end
end

function spectra_rspd = spectra2rspd(spectra)
    global d65;
    [n_spectra, n_lambdas] = size(spectra);
    
    spectra_rspd = zeros(n_spectra, n_lambdas);
    for i = 1:n_spectra
        spectra_rspd(i, :) = spectra(i, :) .* d65;
    end
end

function perturbations_rspd = perturbation2rspd(perturbations)
    global d65;
    [n_spectra, n_lambdas, n_copies] = size(perturbations);
    
    perturbations_rspd = zeros(n_spectra, n_lambdas, n_copies);
    for i = 1:n_spectra
        for j = 1:n_copies
            perturbations_rspd(i, :, j) = perturbations(i, :, j) .* d65;
        end
    end
end


function valid = compute_valid_rgb(p_rgb)
    [m, ~, o] = size(p_rgb);
    valid = true(m, o);
    
    for i = 1:m
        for j = 1:o
            valid(i, j) = ...
                all(p_rgb(i, :, j) >= 0) && ...
                all(p_rgb(i, :, j) <= 1);
        end
    end
end

