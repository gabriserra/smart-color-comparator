% ----------------------------------------
% SELECT_MASTER.m
%
% Select master from SOM or load it from
% previously saved file
% ----------------------------------------

% ----------------------------------------
% MAIN & CONSTANTS
% ----------------------------------------

function master = select_master(mode, som)
    dt_path = 'smart-color-comparator/data/';
    dt_master = 'master_list.mat';
    n_master = 450;
    
    switch mode
        case 'load'
            master = load_master(dt_path, dt_master);
        case 'reload'
            master = reload_master(n_master, dt_path, dt_master, som);
        otherwise
            error('Mode not supported.');
    end
end

% ----------------------------------------
% FUNCTIONS
% ----------------------------------------

% load_master(dt_path, dt_master)
%
% The function will load the master list and store into a
% variable of workspace
%
% master [450 x 1]

function master = load_master(dt_path, dt_master)
    dataset_path = strcat(dt_path, dt_master);
    vars = load(dataset_path, 'master');

    master = vars.master;
end

% reload_master(n_master, dt_path, dt_master, som)
%
% The function will re-select the masters
%
% master [450 x 1]

function master = reload_master(n_master, dt_path, dt_master, som)
    dataset_save_path = strcat(dt_path, dt_master);
    [n_neurons, n_samples] = size(som);
    
    master = zeros(n_master, 1);
    n = 1;
    
    % Decide how many samples per neuron
    n_round = floor(n_master / n_neurons);
    
    % Select first using SOM
    for loop = 1:n_round
        for i = 1:sqrt(n_neurons)
            for j = 1:sqrt(n_neurons)
                for k = 1:n_samples
                    if(som((i-1) * sqrt(n_neurons) + j, k))
                        master(n) = k;
                        n = n + 1;
                        som((i-1) * sqrt(n_neurons) + j, k) = 0;
                        break;
                    end
                end
            end
        end
    end
    
    % If someone is empty, select the remaining ones randomly
    for m = n:n_master
        out = 0;
        while(out == 0)
            x = randi(sqrt(n_neurons), 1);
            y = randi(sqrt(n_neurons), 1);
            for k = 1:n_samples
                out = som((x-1) * sqrt(n_neurons) + y, k);
                if(out)
                    master(m) = k;
                    som((x-1) * sqrt(n_neurons) + y, k) = 0;
                    break;
                end
            end
        end
    end
    
    save(dataset_save_path, 'master');
end