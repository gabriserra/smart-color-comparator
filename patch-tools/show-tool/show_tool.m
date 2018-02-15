% ----------------------------------------
% SHOW_TOOL.m
%
% Show in a smart way the set of patches
% and the disturbed ones
% ----------------------------------------

% ----------------------------------------
% MAIN & CONSTANTS
% ----------------------------------------

function show_tool(rgb, p_rgb, set, mode, master_list)
    switch set
        case 'original'
            if(mode == '2D')
                draw_cube_simple_flat(rgb);
            elseif (mode == '3D')
                draw_cube_simple(rgb);
            else
                error('Mode can be only 2D or 3D!');
            end
        case 'both'
            if(mode == '2D')
                draw_cube_perturbated_flat(rgb, p_rgb);
            elseif (mode == '3D')
                draw_cube_perturbated(rgb, p_rgb);
            else
                error('Mode can be only 2D or 3D!');
            end
        case 'pairs'
            show_couples(rgb, p_rgb, mode);
        case 'som'
            if(mode == '2D')
                show_map_flat(rgb, p_rgb);
            elseif (mode == '3D')
                show_map(rgb, p_rgb);
            else
                error('Mode can be only 2D or 3D!');
            end
        case 'som_perturbation'
            show_map_perturbation(rgb, p_rgb)
        case 'spd'
            show_spd(rgb, p_rgb);
        case 'master'
            if(mode == '2D')
                show_masters(rgb, p_rgb);
                axis([0 21 0 22]);
                show_selected_masters(p_rgb);
            elseif(mode == '3D')
                show_lab_master(master_list, p_rgb, rgb);
            else
                error('Mode can be only 2D or 3D!');
            end
        otherwise
            error('Unsupported version of set: %s', set);
    end
end

% ----------------------------------------
% FUNCTIONS
% ----------------------------------------

% draw_cube_simple(rgb)
%
% The function will generate a 3D figure that shows RGB colors of
% original patches.

function draw_cube_simple(rgb)
    [n, ~] = size(rgb);
    
    fac = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
    vert_init = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
    vert = vert_init;
    
    x = 0; y = 0;
    
    for i = 1:n
        patch('Vertices', vert, 'Faces', fac, ...
            'FaceVertexCData', rgb(i, :), 'FaceColor','flat');
        
        [x, y] = add_with_module(x, y, sqrt(n));        
        vert(:, 1) = vert_init(:, 1) + x;
        vert(:, 2) = vert_init(:, 2) + y;
    end
    
    view(3);
end

% draw_cube_simple_flat(rgb)
%
% The function will generate a 2D figure that shows RGB colors of
% original patches.

function draw_cube_simple_flat(rgb)
    [n, ~] = size(rgb);
    
    vertex_x_init = [0 1 1 0];
    vertex_y_init = [0 0 1 1];
    vertex_x = vertex_x_init;
    vertex_y = vertex_y_init;
    
    x = 0; y = 0;
    
    for i = 1:n
        
        if(all(rgb(i, :) >= 0) && all(rgb(i, :) <= 1))
            patch(vertex_x, vertex_y, rgb(i, :));
        end  
        [x, y] = add_with_module(x, y, sqrt(n));
        vertex_x = vertex_x_init + x;
        vertex_y = vertex_y_init + y;
    end
    
    view(2); 
end

% draw_cube_perturbated(rgb)
%
% The function will generate a 3D figure that shows RGB colors of
% original patches and perturbations

function draw_cube_perturbated(rgb, p_rgb)
    draw_cube_simple(rgb)
    [m, ~, o] = size(p_rgb);
    
    fac = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
    vert_init = [0 0 3; 1 0 3; 1 1 3; 0 1 3; 0 0 4; 1 0 4; 1 1 4; 0 1 4];
    vert = vert_init;
    
    x = 0; y = 0; z = 0;
    
    for j = 1:o
        for i = 1:m
            
            if(all(p_rgb(i, :, j) >= 0) && all(p_rgb(i, :, j) <= 1))
                patch('Vertices', vert,'Faces', fac, ...
                    'FaceVertexCData', p_rgb(i, :, j), 'FaceColor', 'flat');
            end

            [y, x] = add_with_module(y, x, sqrt(m));
            vert(:, 1) = vert_init(:, 1) + x;
            vert(:, 2) = vert_init(:, 2) + y;

        end
        
        z = z + 3; x = 0; y = 0;
        vert(:, 1) = vert_init(:, 1);
        vert(:, 2) = vert_init(:, 2);
        vert(:, 3) = vert_init(:, 3) + z;
    end
    
    view(3);
end

% draw_cube_perturbated_flat(rgb)
%
% The function will generate a 2D figure that shows RGB colors of
% original patches and perturbations

function draw_cube_perturbated_flat(rgb, p_rgb)
    draw_cube_simple_flat(rgb);
    [m, ~, o] = size(p_rgb);
        
    vertex_x_init = [40 41 41 40];
    vertex_y_init = [0 0 1 1];
    vertex_x = vertex_x_init;
    vertex_y = vertex_y_init;
        
    x = 0; y = 0; z = 0;
    
    for j = 1:o
        for i = 1:m
            
            if(all(p_rgb(i, :, j) >= 0) && all(p_rgb(i, :, j) <= 1))
                patch(vertex_x, vertex_y, p_rgb(i, :, j));
            end

            [y, x] = add_with_module(y, x, sqrt(m));
            vertex_x = vertex_x_init + x + (z * 40);
            vertex_y = vertex_y_init + y;
        end
        
        z = z + 1; x = 0; y = 0;
        vertex_x = vertex_x_init + x + (z * 40);
        vertex_y = vertex_y_init + y;
    end
    
    view(2); 
end

% add_with_module(row, column, module)
%
% Add 1 to row. If row is greater than module, row is resetted
% and column incremented by 1. Module is not used to improve
% time efficency

function [row, column] = add_with_module(row, column, module)
    row = row + 1;
    if (row > (module-1))
        row = 0;
        column = column + 1;
    end
end

% show_couples(rgb, p_rgb, pairs_rating)
%
% Show couples of tagged color. Every 10 couple, enter must be
% pressed to continue

function show_couples(rgb, p_rgb, pairs_rating)
    hold on;
    [n, ~] = size(pairs_rating);
    
    vertex_x_1 = [0 1 1 0];
    vertex_x_2 = [1 2 2 1];
    vertex_y_init = [0 0 1 1];
    vertex_y = vertex_y_init;
    
    y = 0;
    
    for i = 1:n
        rgb_orig = rgb(pairs_rating(i, 2), :);
        rgb_pert = p_rgb(pairs_rating(i, 2), :, pairs_rating(i, 3));
        
        valid = all(rgb_pert >= 0) && all(rgb_pert <= 1);
        
        if(valid)
            patch(vertex_x_1, vertex_y, rgb_orig, 'EdgeColor',rgb_orig);
            patch(vertex_x_2, vertex_y, rgb_pert, 'EdgeColor',rgb_pert);
        end
        
        y = y + 1;
        vertex_y = vertex_y_init + y;
        
        if(mod(i, 10) == 0)
            view(2);
            waitforbuttonpress;
            clf;
        end
    end     
end

% show_map_flat(output, rgb)
%
% Show Self-Organized-Map output in  a clever way (2D).

function show_map_flat(rgb, output)
    [n_neuro, n_patches] = size(output);
    
    vertex_x_init = [0 1 1 0];
    vertex_y_init = [0 0 1 1];
    vertex_x = vertex_x_init;
    vertex_y = vertex_y_init;
    
    x = 0; y = 0;
    
    for i = 1:n_neuro
        for j = 1:n_patches
            if(output(i, j))
                patch(vertex_x, vertex_y, rgb(j, :));
                y = y + 1;
            end
                   
            vertex_x = vertex_x_init + x;
            vertex_y = vertex_y_init + y;
        end
        x = x + 1; y = 0;
    end
    
    view(2); 
end

% show_map(output, rgb)
%
% Show Self-Organized-Map output in  a clever way (3D).

function show_map(rgb, output)
    [n_neuro, n_patches] = size(output);
    
    fac = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
    vert_init = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
    vert = vert_init;
    
    x = 0; y = 0; z = 0;
    
    for i = 1:sqrt(n_neuro)
        for j = 1:sqrt(n_neuro)
            for k = 1:n_patches
                if(output((i-1) * sqrt(n_neuro) + j, k))
                    patch('Vertices', vert,'Faces', fac, ...
                        'FaceVertexCData', rgb(k, :), 'FaceColor', 'flat');
                    z = z + 1;
                    
                end

                vert(:, 3) = vert_init(:, 3) + z;
            end
            z = 0; y = y + 1;
            
            vert(:, 2) = vert_init(:, 2) + y;
            vert(:, 3) = vert_init(:, 3);
        end
        x = x + 1; y = 0; z = 0;
        vert(:, 1) = vert_init(:, 1) + x;
        vert(:, 2) = vert_init(:, 2);
        vert(:, 3) = vert_init(:, 3);
    end
    
    view(3);
end

% show_map_perturbation(output, rgb)
%
% Show Self-Organized-Map output in  a clever way (3D).

function show_map_perturbation(p_rgb, output)
    [n_neuro, n_patches] = size(output);
    [n_original, ~, n_copies] = size(p_rgb);
    
    fac = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
    vert_init = [0 0 0; 1 0 0; 1 1 0; 0 1 0; 0 0 1; 1 0 1; 1 1 1; 0 1 1];
    vert = vert_init;
    
    x = 0; y = 0; z = 0;
    
    for i = 1:sqrt(n_neuro)
        for j = 1:sqrt(n_neuro)
            for k = 1:n_patches
                if(output((i-1) * sqrt(n_neuro) + j, k))
                    copies_num = ceil(k / n_original);
                    master_num = mod(k, n_original);
                    
                    if(master_num == 0)
                        master_num = n_original;
                    end
                                        
                    patch('Vertices', vert,'Faces', fac, ...
                        'FaceVertexCData', p_rgb(master_num, :, copies_num), 'FaceColor', 'flat');
                    z = z + 1;
                    
                end

                vert(:, 3) = vert_init(:, 3) + z;
            end
            z = 0; y = y + 1;
            
            vert(:, 2) = vert_init(:, 2) + y;
            vert(:, 3) = vert_init(:, 3);
        end
        x = x + 1; y = 0; z = 0;
        vert(:, 1) = vert_init(:, 1) + x;
        vert(:, 2) = vert_init(:, 2);
        vert(:, 3) = vert_init(:, 3);
    end
    
    view(3);
end

% show_spd(spectra, lambdas)
%
% Show spectral power distribution of a color.

function show_spd(spectra, lambdas)

    if size(lambdas,1) ~= size(spectra,1)
        error('Array MUST be of the same size.');
    end
     
    y_axis = [380 800 min(spectra) max(spectra)];
    rgb = spectrum_rgb(lambdas, '1931_FULL');
     
    axis(y_axis);
     
    b = bar(lambdas', spectra, 'hist' , 'LineStyle','none');
    set(b, 'CData', rgb(1,:,:), 'CDataMapping', 'direct', 'EdgeColor', 'none');
end

% show_masters(rgb, master)
%
% The function will generate a 2D figure that shows RGB colors of
% original patches.

function show_masters(rgb, master)
    n_master = size(master, 1);
    
    rgb_master = zeros(n_master, 3);
    for i = 1:n_master
        rgb_master(i, :) = rgb(master(i), :);
    end
    
    vertex_x_init = [0 1 1 0];
    vertex_y_init = [0 0 1 1];
    vertex_x = vertex_x_init;
    vertex_y = vertex_y_init;
    
    x = 0; y = 0;
    
    for i = 1:n_master
        patch(vertex_x, vertex_y, rgb_master(i, :));
                
        [x, y] = add_with_module(x, y, sqrt(n_master));
        vertex_x = vertex_x_init + x;
        vertex_y = vertex_y_init + y;
    end
    
    view(2); 
end

% show_lab_master(master_list, lab, rgb)
%
% The function will generate a 3D figure that shows RGB colors of
% masters in lab space.

function show_lab_master(master_list, lab, rgb)
    
    % Create a sphere
    [X, Y, Z] = sphere();
    X = X .* 100;
    Y = Y .* 100;
    Z = Z .* 50 + 50;
            
    % Select point from lab list
    n_master = size(master_list, 1);
    new_lab = zeros(n_master, 3);
    new_rgb = zeros(n_master, 3);
    
    for i = 1:n_master
        master = master_list(i);
        new_lab(i, :) = lab(master, :);
        new_rgb(i, :) = rgb(master, :);
    end
            
    plot3(X, Y, Z, 'Color', [0.5 0.5 0.5]);
    hold on;
    scatter3(new_lab(:,2)', new_lab(:,3)', new_lab(:,1)', [], new_rgb, 'filled');
    
end

% show_selected_masters(master)
%
%
% The function will generate a 2D figure that shows RGB colors of
% original patches.

function show_selected_masters(master)
    n_master = size(master, 1);
    
    [trainInd, valInd, testInd] = divideint(n_master, 0.7, 0.15, 0.15);
    
    rgb_master_train = zeros(n_master, 3);
    rgb_valid_train = zeros(n_master, 3);
    rgb_test_train = zeros(n_master, 3);
    
    for i = 1:length(trainInd)
        rgb_master_train(trainInd(i), :) = [1 0 0]; 
    end
    
    for i = 1:length(valInd)
        rgb_valid_train(valInd(i), :) = [1 0 0];
        rgb_test_train(testInd(i), :) = [1 0 0];
    end
    
    figure;
    axis([0 21 0 22]);
    draw_cube_simple_flat(rgb_master_train);
    
    figure;
    axis([0 21 0 22]);
    draw_cube_simple_flat(rgb_valid_train);
    
    figure;
    axis([0 21 0 22]);
    draw_cube_simple_flat(rgb_test_train);

end