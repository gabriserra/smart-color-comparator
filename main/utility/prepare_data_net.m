% ----------------------------------------
% PREPARE_DATA_NET.m
%
% Prepare data to be ready for NN
% ----------------------------------------

% ----------------------------------------
% MAIN & CONSTANTS
% ----------------------------------------

% prepare_data_net(wavelengths, step, spectra, perturbations, pairs, ratings)
%
% Prepare data in input/output to work with MLP/RBF network
%
% input  [?]
% target [?]

function [input, target] = prepare_data_net(wavelengths, spectra, perturbations, pairs, ratings)    
    [n_pairs, ~] = size(pairs);
    n_wavel = size(wavelengths, 1);
    
    ratings = ratings';
    
    %input = zeros(n_pairs, n_wavel-1);
    %target = zeros(n_pairs, 2);
    set = zeros(n_pairs, n_wavel + 3);
    
    for i = 1:n_pairs
        n_master = pairs(i, 1);
        n_pert = pairs(i, 2);
        
        master_tmp = under_sampling(spectra(n_master, :), 2)';
        copy_tmp = under_sampling(perturbations(n_master, :, n_pert), 2)';
        
        if(ratings(i) == 1)
            rate_tmp = [1 0];
        else
            rate_tmp = [0 1];
        end
       
        set(i, :) = [n_master n_pert master_tmp copy_tmp rate_tmp];
    end
    
    set = sortrows(set);
    input = set(:, 3:n_wavel+1);
    target = set(:, n_wavel+2:end);  
end

% under_sampling(lambdas, step)
%
% The function undersampling computes the undersampling operation 
% on the lambdas vector taking wavelengths with a specified step.
%
% un_lambdas  [?]

function [un_lambdas] = under_sampling(lambdas, step)
    if size(lambdas,1) == 1
        lambdas = lambdas';
    end 
     
    un_lambdas = zeros(floor(size(lambdas,1)/step), 1);
     
    for i = 1: 1: size(lambdas,1)
        if(mod(i,step) == 0)
            un_lambdas(i/step) = lambdas(i);
        end
    end
end