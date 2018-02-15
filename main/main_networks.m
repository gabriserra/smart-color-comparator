%% LOAD DATA SET
load('./smart-color-comparator/data/rspds_200.mat');
load('./smart-color-comparator/data/evaluation_200.mat');
wavelengths = (380:800)';

%% PREPARE DATA TO PROVIDE TO THE NETWORK
[input, targets] = prepare_data_net(wavelengths, spectra_rspd, perturbations_rspd, pairs, ratings);

%% CALL NET
%best_n = mlp_pat_net(input, targets);
%best_n = mlp_fit_net(input, targets);
%best_n = rbf_network(input, targets);

%% BUILD ROC
% FITNET 1 - 1261 + 13 | 16 + 510 -> TPR = 0.9898 - FPR = 0.0304
% FITNET50 - 972 + 175 | 39 + 614 -> TRP = 0.8474 - FPR = 0.0597
% FITNET200- 949 + 196 | 108 + 547-> TRP = 0.8288 - FPR = 0.1649
 
% PATTER 1 - 1262 + 12 | 10 + 516 -> TPR = 0.9906 - FPR = 0.0190
% PATTER50 - 1015 + 132| 105 + 548-> TPR = 0.8849 - FPR = 0.1608
% PATTERN200-1007 + 138| 191 + 464-> TPR = 0.8795 - FPR = 0.2916

% RBF1 - 373 + 18 | 4 + 149 -> TPR = 0.9540 - FPR = 0.0070
% RBF50- 333 + 1 | 199 + 11 -> TPR = 0.9970 - FPR = 0.9476
% RBF200-343 + 0 | 192 + 9  -> TPR = 1.0000 - FPR = 0.9552

fitnet_tpr = [0.9898 0.8474 0.8288];
fitnet_fpr = [0.0304 0.0597 0.1649];
pattern_tpr = [0.9906 0.8849 0.8795];
pattern_fpr = [0.0190 0.1608 0.2916];
rbf_tpr = [0.9540 0.9970 1.0000];
rbf_fpr = [0.0070 0.9476 0.9552];
random_tpr = [0 1];
random_fpr = [0 1];

plot(fitnet_fpr, fitnet_tpr, '-or', pattern_fpr, pattern_tpr, '-ob', rbf_fpr, rbf_tpr, '-ok', random_fpr, random_tpr, '--g');
title('ROC curves');
xlabel('FPR');
ylabel('TPR');
legend('Fitnet ROC curve', 'Patternet ROC curve', 'RBF ROC curve');
