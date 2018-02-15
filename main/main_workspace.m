%% INIT PSEUDO-RANDOM SEED
rng(1);

%% LOAD INITIAL DATASET
[spectra, wavelengths, perturbations] = load_data('load');

%% CALCULATE RGB/XYZ AND SHOW THE INITIAL DATASET PLUS PERTURBATION
[spectra_rspd, perturbations_rspd, xyz, rgb, lab, p_xyx, p_rgb, p_lab, valid_rgb] = convert_lib(spectra, perturbations);

% show initial data set
% figure
% show_tool(rgb, lab, 'master', '3D', [1:1232]')
% figure;
% show_tool(rgb, p_rgb, 'original', '2D');
% waitforbuttonpress;

% show perturbations
% figure;
% show_tool(rgb, p_rgb, 'both', '3D');
% waitforbuttonpress;

%% LOAD SOM AND SHOW IT
[som, net] = load_som('spectra', 15);

% figure;
% show_tool(p_rgb, output, 'som', '3D');
% waitforbuttonpress;

%% SELECT MASTER FROM SOM AND SHOW IT
master = select_master('load', som); % 450 di cui 434 presi con la SOM

% figure;
% show_tool(rgb, master, 'master', '2D');
% figure
% show_tool(rgb, lab, 'master', '3D', master)
% waitforbuttonpress;

%% GET TAGGED OBJECT AND SHOW COUPLES
[pairs, ratings] = load_evaluation('load');

% pairs_rating = [ratings' pairs];
% pairs_rating = sortrows(pairs_rating);
% show_tool(rgb, p_rgb, 'pairs', pairs_rating);