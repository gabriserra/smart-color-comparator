% --------------------------------------------
% SPECTRUM_RGB.m
%
% Converts a spectral wavelength to RGB 
% ---------------------------------------------

% ----------------------------------------
% MAIN & CONSTANT
% ----------------------------------------

% spectrum_rgb(lambdas, varargin)
%
% The function converts lambdas to rgb using the
% color matching function match, a string. 
% 
% rgb [? x 3]

function rgb = spectrum_rgb(lambdas, match)
    
    if (numel(lambdas) ~= length(lambdas))
        error('Input must be a scalar or vector of wavelengths.');
    end

    % Get the color matching functions.
    [lambda, x_fun, y_fun, z_fun] = color_matching_functions(match);

    % Interpolate the input wavelength in the color matching functions.
    XYZ = interp1(lambda', [x_fun; y_fun; z_fun]', lambdas, 'pchip', 0);

    % Reshape interpolated values to match standard image representation.
    if (numel(lambdas) > 1)
        XYZ = permute(XYZ', [3 2 1]);
    end

    % Convert the XYZ values to sRGB.
    XYZ2sRGB = makecform('xyz2srgb');
    rgb = applycform(XYZ, XYZ2sRGB);
end