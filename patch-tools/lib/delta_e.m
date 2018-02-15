% ---------------------------------------------------
% DELTA_E.m
%
% Permit to evaluate color difference starting from 
% 2 lab colors.
% More: https://en.wikipedia.org/wiki/Color_difference
% ----------------------------------------------------

% ----------------------------------------
% MAIN & CONSTANTS
% ----------------------------------------

function y = delta_e(lab1, lab2, version)
    delta_e_default = 'CIE76';
    
    if nargin < 3
        version = delta_e_default;
    end
    
    y = compute_delta_e(lab1, lab2, version);
end


% ----------------------------------------
% FUNCTIONS
% ----------------------------------------

% compute_delta_e(lab1, lab2, version)
%
% The function will evaluate the perceptual difference between two lab 
% colors. It is possible to choose the version to compute the calculation.
%
% y [1]

function y = compute_delta_e(lab1, lab2, version)
    switch version
        case 'CIE76'
            y = delta_e_76(lab1, lab2);
        case 'CIE94'
            y = delta_e_94(lab1, lab2);
        case 'CIEDE2000'
            y = delta_e_2000(lab1, lab2);
        otherwise
            error('Unsupported version of deltae: %s', version);
    end
end

% delta_e_76(lab1, lab2)
%
% The function will evaluate the difference between two lab colors using
% the definition of CIE 1976
% https://en.wikipedia.org/wiki/Color_difference#CIE76
%
% y [1]

function y = delta_e_76(lab1, lab2)
    y = norm(lab1 - lab2);
end

% delta_e_94(lab1, lab2)
%
% The function will evaluate the difference between two lab colors using
% the definition of CIE 1994
% https://en.wikipedia.org/wiki/Color_difference#CIE94
%
% y [1]

function y = delta_e_94(lab1, lab2)
    l1 = lab1(1);
    a1 = lab1(2);
    b1 = lab1(3);

    l2 = lab2(1);
    a2 = lab2(2);
    b2 = lab2(3);

    deltaL      = l1 - l2;
    deltaA      = a1 - a2;
    deltaB      = b1 - b2;

    C1          = sqrt(a1^2 + b1^2);
    C2          = sqrt(a2^2 + b2^2);
    deltaCab    = C1 - C2;
    deltaHab    = sqrt(deltaA^2 + deltaB^2 + deltaCab^2);

    KL          = 2;
    KC          = 1;
    KH          = 1;
    K1          = 0.048;
    K2          = 0.014;

    SL          = 1;
    SC          = 1 + K1*C1;
    SH          = 1 + K2*C2;

    LL          = deltaL    / (KL * SL);
    AA          = deltaCab  / (KC * SC);
    BB          = deltaHab  / (KH * SH);

    y           = sqrt(LL^2 + AA^2 + BB^2);
end

% delta_e_2000(lab1, lab2)
%
% The function will evaluate the difference between two lab colors using
% the definition of CIEDE 2000
% https://en.wikipedia.org/wiki/Color_difference#CIEDE2000
%
% y [1]

function y = delta_e_2000(lab1, lab2)
    % TO DO
    error('CIEDE 2000 - Currently in development. Sorry.');
end
