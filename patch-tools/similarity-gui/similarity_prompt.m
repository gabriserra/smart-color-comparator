% ----------------------------------------
% SIMILARITY_PROMPT.m
%
% A prompt-GUI that help to tag color in order 
% to create a ground truth
% ----------------------------------------

% -------------------------------------------
% GUI EVENT HANDLERS
% -------------------------------------------

% Execute when GUI script is called.
function varargout = similarity_prompt(varargin)

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @similarity_prompt_OpeningFcn, ...
                       'gui_OutputFcn',  @similarity_prompt_OutputFcn, ...
                       'gui_LayoutFcn',  [], ...
                       'gui_Callback',   []);

    if nargin && ischar(varargin{1})
       gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

% Executes just before similarity_prompt is made visible.
function similarity_prompt_OpeningFcn(hObject, ~, handles, varargin)

    % Choose default command line output for similarity_prompt
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % Load from argin
    [fname, rgb, p_rgb, master_list, ratings, pairs] = opening_argin_check(varargin{:});

    % Get the number of perturbations for each original spectrum
    [n_sp, ~, n_per] = size(p_rgb);

    % Load constants needed by the GUI
    consts = load_constants(fname, rgb, n_sp, p_rgb, n_per, master_list);

    % Load global variables needed by the GUI
    globals = load_globals(ratings, pairs, n_sp, n_per);

    % Saving data into persistent 'handles'
    handles.consts  = consts;
    handles.globals = globals;

    % Generating first state
    handles = change_state(handles, 1, true);

    % Refresh GUI
    guidata(hObject, handles);
end

% Executes during object creation, after setting all properties.
function similarityPrompt_CreateFcn(hObject, ~, handles)

    % Refresh GUI
    guidata(hObject, handles);
end

% Outputs from this function are returned to the command line.
function varargout = similarity_prompt_OutputFcn(~, ~, handles)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% Executes when user attempts to close similarity_prompt.
function similarityPrompt_CloseRequestFcn(~, ~, handles)

    % Call closing callback
    similarityPrompt_closingCallback(handles, false); 
end

% Executes when GUI is closed.
function similarityPrompt_closingCallback(handles, save_data)

    % Save data if needed
    if(save_data)
        save_progess(handles);
    end
    
    % Delete handles
    if isfield(handles, 'similarityPrompt')
        delete(handles.similarityPrompt);
    end
end

% -------------------------------------------
% BUTTON CALLBACKS
% -------------------------------------------

% Executes on button press in btnNext.
function btnNext_Callback(hObject, ~, handles)

    % Go to next patch
    handles = change_state(handles, 1, false);
    guidata(hObject, handles);
end

% Executes on button press in btnBack.
function btnBack_Callback(hObject, ~, handles)

    % Go to previous patch
    handles = change_state(handles, -1, false);
    guidata(hObject, handles);
end

% Executes on button press in btnCancel.
function btnCancel_Callback(~, ~, handles)

    % Call closing callback
    similarityPrompt_closingCallback(handles, false);
end

% Executes on button press in btnFinish.
function btnFinish_Callback(~, ~, handles)

    % Call closing callback
    similarityPrompt_closingCallback(handles, true);
end

% Executes on button press in showDeltaE.
function showDeltaE_Callback(hObject, ~, handles)

    % Toggle deltaE in GUI and refresh
    handles.state.show_deltaE = not(handles.state.show_deltaE);
    handles = update_deltae_tab(handles);
    guidata(hObject, handles);
end

% Executes when selected object is changed in similarityLevel.
function similarityLevel_SelectionChangedFcn(hObject, ~, handles)

    % Toggle ON deltaE in GUI and refresh
    handles.state.show_deltaE = true;
    handles = update_deltae_tab(handles);
    guidata(hObject, handles);
end

% -------------------------------------------
% KEYBOARD CALLBACKS
% -------------------------------------------

% Executes on key press with focus on similarityPrompt and none of its controls.
function similarityPrompt_KeyPressFcn(hObject, eventdata, handles)
    
    switch eventdata.Key
        case '1'
            handles.similarityLevel.SelectedObject = handles.radio1;
        case '2'
            handles.similarityLevel.SelectedObject = handles.radio2;
        case 'backspace'
            btnBack_Callback(hObject, eventdata, handles)
        case 'return'
            btnNext_Callback(hObject, eventdata, handles);
    end
end

% -------------------------------------------
% CHANGE STATE FUNCTIONS
% -------------------------------------------

% change_state(handles, move, first_call)
%
% Manage state actions
%
% handles   GUI handles struct

function handles = change_state(handles, move, first_call)
    if move == 1
        
        if ~first_call
            handles = update_state(handles);
        end
        
        how_many_visited = length(handles.globals.ratings);
        show_histogram(handles, how_many_visited)
    end

    handles.globals.current_pair = handles.globals.current_pair + move;
    
    if handles.globals.current_pair < 1
        handles.globals.current_pair = 1;
    end

    idx = handles.globals.current_pair;

    if idx > length(handles.globals.ratings)
        % Generating a new pair
        valid = false;
        while not(valid)

            if how_many_visited + handles.globals.invalid ...
                    >= handles.consts.n_pairs
                similarityPrompt_closingCallback(handles, true);
                return;
            end

            [handles, current_rgb, current_p_rgb] = get_indexes_from_list(handles);

            [handles, valid] = generate_state(handles, current_rgb, current_p_rgb);

            if not(valid)
                handles.globals.invalid = handles.globals.invalid + 1;
            end
        end
    else
        current_rgb = handles.globals.pairs(idx, 1);
        current_p_rgb = handles.globals.pairs(idx, 2);

        handles = generate_state(handles, current_rgb, current_p_rgb);
    end

    handles = show_state(handles);
end

% update_state(handles)
%
% Update and save ratings/pairs/visited state 
%
% handles   GUI handles struct

function handles = update_state(handles)

    if handles.globals.current_pair < 1
        return;
    end

    rating = get_saved_rating(handles);

    current_pair = handles.globals.current_pair;
    current_rgb = handles.state.current_rgb;
    current_p_rgb = handles.state.current_p_rgb;

    handles.globals.ratings(current_pair) = rating;
    handles.globals.pairs(current_pair, :) = [current_rgb, current_p_rgb];
    handles.globals.visited(current_rgb, current_p_rgb) = true;
end

% [handles, valid] = generate_state(handles, current_rgb, current_p_rgb)
%
% Retrieve RGBs to be displayed and their deltaE
%
% handles   GUI handles struct
% valid     RGB is a valid triplet

function [handles, valid] = generate_state(handles, current_rgb, current_p_rgb)

    handles.state = [];

    handles.state.current_rgb = current_rgb;
    handles.state.current_p_rgb = current_p_rgb;

    handles.state.orig = [];
    handles.state.orig.rgb = handles.consts.rgb(current_rgb, :);

    handles.state.pert = [];
    handles.state.pert.rgb = handles.consts.p_rgb(current_rgb, :, current_p_rgb);

    valid = all(handles.consts.p_rgb(current_rgb, :, current_p_rgb) >= 0) && ...
            all(handles.consts.p_rgb(current_rgb, :, current_p_rgb) <= 1);

    if not(valid)
        return;
    end
    
    lab_orig = rgb2lab(handles.state.orig.rgb);
    lab_pert = rgb2lab(handles.state.pert.rgb);

    handles.state.deltaE = delta_e(lab_orig, lab_pert, 'CIE94');
end

function handles = show_state(handles)

    % Show deltaE value
    handles.state.show_deltaE = true;
    handles = update_deltae_tab(handles);

    % Showing currently selected radio button
    handles.similarityLevel.SelectedObject = get_selected_radiobutton(handles);

    % Updating progressRatio
    how_many_visited = length(handles.globals.ratings) + handles.globals.invalid;
    progressRatio = how_many_visited / handles.consts.n_pairs * 100;
    progressRatio = floor(progressRatio * 10) / 10;
    handles.progressRatio.String = ...
        [mat2str(length(handles.globals.ratings)), '  pairs       ', ...
        mat2str(progressRatio), ' / 100'];

    % Showing current patches
    axis(handles.patches);
    cla(handles.patches, 'reset');
    patch([0 1 1 0], [1 1 0 0], handles.state.orig.rgb, 'EdgeColor',handles.state.orig.rgb);
    patch([1 2 2 1], [1 1 0 0], handles.state.pert.rgb, 'EdgeColor',handles.state.pert.rgb);
    set(handles.patches, 'XTick', []);
    set(handles.patches, 'YTick', []);
end

% -------------------------------------------
% UTILITY FUNCTIONS
% -------------------------------------------

% opening_argin_check(varargin)
%
% The function will check passed argument. Needed variable are loaded
% from file or load from argin/created
%
% filename      "string"
% rgb           [1225 x 3]
% p_rgb         [1225 x 3 x 5]
% ratings       []
% pairs         []

function [fname, rgb, p_rgb, master_list, ratings, pairs] = opening_argin_check(varargin)

    % no input argument
    if length(varargin) < 1 || length(varargin) == 2
        error('Error opening GUI: bad input argument.');
    end
            
    % bad file parameter
    if (length(varargin) < 2 && ~exist(varargin{1}, 'file'))
        error('No file passed in.');
    end
    
    % file name passed
    if length(varargin) < 2
        fname           = varargin{1};
        vars            = load(fname, 'rgb', 'p_rgb', 'master_list','ratings', 'pairs');
        rgb             = vars.rgb;
        p_rgb           = vars.p_rgb;
        master_list     = vars.master_list;
        ratings         = vars.ratings;
        pairs           = vars.pairs;
    
    % new file must be created
    else
        fname           = '';
        rgb             = varargin{1};
        p_rgb           = varargin{2};
        master_list     = varargin{3};
        ratings         = [];
        pairs           = [];
    end
end

% load_constants(fname, rgb, n_sp, p_rgb, n_per)
%
% The function load into a structure all constant needed by the GUI
%
% consts      struct
%   fname       save filename
%   rgb         original spectra rgb
%   p_rgb       perturbation matrix rgb
%   n_spectra   default: 1225
%   n_perturb   default: 5
%   master_list default: ?

function consts = ...
                 load_constants(fname, rgb, n_sp, p_rgb, n_per, master_list)
    
    consts = [];
    consts.fname = fname;
    consts.rgb = rgb;
    consts.p_rgb = p_rgb;        
    consts.n_spectra = n_sp;
    consts.n_perturbations = n_per;
    consts.n_pairs = n_sp * n_per;
    consts.master_list = master_list;
end

% load_globals(ratings, pairs, n_sp, n_per)
%
% The function load into a structure all gloabal variable needed by the GUI
%
% globals           struct
%   ratings         contains rating assigned
%   pairs           original spectra paired with disturbations
%   visited         already compared by user
%   current_pair    current selected pair

function globals = load_globals(ratings, pairs, n_sp, n_per)
    
    globals = [];
    globals.ratings = ratings;
    globals.pairs = pairs;
    globals.invalid = 0;
    globals.visited = false(n_sp, n_per);
    [globals.visited, globals.current_pair] = ...
                                      set_visisted(globals.visited, pairs);
end

% set_visisted(visited, pairs)
%
% The function set to true entry relative to already tagged pairs
%
% visited     already compared by user
% current     current selected pair
    
function [visited, current_pair] = set_visisted(visited, pairs)
    [current_pair, ~] = size(pairs);
  
    for i = 1:current_pair
        visited(pairs(i, 1), pairs(i, 2)) = true;
    end
end

% save_progess(handles)
%
% The function permanently save progress into file

function save_progess(handles)
    if isempty(handles.globals.ratings)
        fprintf('\nTraining set generation aborted by user.\n\n');
        return;
    end
    
    [inserted, filename, pathname] = dialog_box(handles.consts.fname);
    
    if not(inserted)
        fprintf('\nTraining set generation aborted by user.\n\n');
    end

    savefile = fullfile(pathname,filename);

    rgb = handles.consts.rgb;
    p_rgb = handles.consts.p_rgb;
    ratings = handles.globals.ratings;
    pairs = handles.globals.pairs;
    master_list = handles.consts.master_list;

    save(savefile, 'rgb', 'p_rgb', 'ratings', 'pairs', 'master_list');
    fprintf('\nData saved in the following location:\n%s\n\n', savefile);
end

% dialog_box(filename)
%
% Open dialog box and request for input user
%
% inserted    indicate if dialog has been closed without insert data
% filename    inserted filename
% pathname    inserted pathname

function [inserted, filename, pathname] = dialog_box(filename)

    if isempty(filename)
        h = msgbox('Insert file name and location for your data.\nThe default file searched when training the actual network is the one contained in folder ''train'' called ''training.mat''.');
        filename = 'training.mat';
    else
        h = msgbox(['You will now be asked for a file name and location for your data.\nRemember that you initially loaded previous data from file ''' filename '''.']);
    end
    
    waitfor(h);
    [filename, pathname] = uiputfile(filename, 'Save Training Data');
    inserted = not(isequal(filename,0)) && not(isequal(pathname,0));
end

% show_histogram(handles, how_many_visited)
%
% Display histogram to view progress

function show_histogram(handles, how_many_visited)
    persistent fig
    
    if how_many_visited > 0 && ~mod(how_many_visited, 50)
        fig = figure;
        histogram(handles.globals.ratings);
        figure(handles.similarityPrompt);
    end
end

% make_move(handles, move)
%
% Get the move (+1 or -1) and update handles struct
%
% curr_pair     the current pair index selected

function curr_pair = make_move(handles, move)

    handles.globals.current_pair = handles.globals.current_pair + move;
    
    if handles.globals.current_pair < 1
        handles.globals.current_pair = 1;
    end

    curr_pair = handles.globals.current_pair;
end

% get_saved_rating(handles)
%
% Get rating associated with radio button selected
%
% rating    vote from 1 to 4

function rating = get_saved_rating(handles)

    switch handles.similarityLevel.SelectedObject.Tag
        case 'radio1'
            rating = 1;
        case 'radio2'
            rating = 2;
        otherwise
            error('Currently selected object is invalid.');
    end
end

% get_selected_radiobutton(handles)
%
% Get selected radio button starting from rating value
%
% obj    one of the radio buttons

function obj = get_selected_radiobutton(handles)

    if handles.globals.current_pair > length(handles.globals.ratings)
        obj = handles.radio1;
        return;
    end

    rating = handles.globals.ratings(handles.globals.current_pair);
    switch rating
        case 1
            obj = handles.radio1;
        case 2
            obj = handles.radio2;
        otherwise
            error('Unexpected rayting value: %d', rating);
    end
end

% update_deltae_tab(handles)
%
% Update deltaE tab in GUI
%
% handles   GUI handles object

function handles = update_deltae_tab(handles)

    handles.showDeltaE.Value = handles.state.show_deltaE;
    handles.textDeltaE.String = mat2str(handles.state.deltaE, 5);

    if(handles.state.show_deltaE)
        handles.textDeltaE.Visible = 'on';
    else
        handles.textDeltaE.Visible = 'off';
    end
end

% generate_rand_indexes(handles)
%
% Generate two random indexes to inside visited matrix
%
% handles       GUI handles object
% current_rgb   Index to address one of the RGB colors
% current_p_rgb Index to address one of the copies

function [handles, current_rgb, current_p_rgb] = ...
                                            generate_rand_indexes(handles)

    visited = true;
    
    while visited
        current_rgb = randi(handles.consts.n_spectra, 1);
        current_p_rgb = randi(handles.consts.n_perturbations, 1);
        visited = handles.globals.visited(current_rgb, current_p_rgb);
    end
end

% get_indexes_from_list(handles)
%
% Generate two random indexes to inside visited matrix
%
% handles       GUI handles object
% current_rgb   Index to address one of the RGB colors
% current_p_rgb Index to address one of the copies

function [handles, current_rgb, current_p_rgb] = ...
                                            get_indexes_from_list(handles)

    visited = true;
    
    while visited
        i = randi(length(handles.consts.master_list), 1);
        current_rgb = handles.consts.master_list(i);
        current_p_rgb = randi(handles.consts.n_perturbations, 1);
        visited = handles.globals.visited(current_rgb, current_p_rgb);
    end
end
