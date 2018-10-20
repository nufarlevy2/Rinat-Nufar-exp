 %TODO: fix bug in ExperimentGuiBuilder::readMultipleNums - if changing
%number of requested numbers, then crash.

function template1()
%% Overview
% This fun ction is a framework for building experiments for psychtoolbox.
% Three main sections:
%
% # Experiment  Definitions
% # GUI
% # Experiment fup nction - called via the gui's [run experiment] button.
%
% ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% 
% The experiment function is broken up to logical stages that make up the
% experiment's workflow: ( _EDIT_ marks stages needed to be edited by the programmer)
%    
% # Turn on psychtoolbox view - _turnOnPTBView_ .
% # Initialize biosemi and the eyetracker and start recording - _initializeGear_ .
% # Load messages and stimuli .png (loads into the struct *resources*) - _scanMessages_ , _loadResources_ : _EDIT_ .
% # Initialize the data record object *EXPDATA* - _initializeDataRecord_ : _EDIT_ .
% # Build the randomized conditions matrix *conditions_mat* - _randomizeConditions_ : _EDIT_
% # Run the experiment - _runBlocks_: _EDIT_ . this function contains a recommended
%    preliminary code. 
% # Save all the data and shut down the recording - _terminateExp_ : in the
%    event of an error during the experiment, _terminateExp_ is called before
%    the experiment shuts down.
%    
% ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%
% At the end of the template you will find miscellaneous utility functions:
%
% * _runCalibrationQuery_ - displays a screen to query the experimenter
%      whether to perform an eye tracker calibration.
% * _calibrateEyeTracker_ - calls the eyelink calibration routine.
% * _echo_ - sends a trigger if the biosemi is active or an eyelink
%   message if only the eyetracker is active.
% * _sendEyelinkMsg_ - sends an eyelink message to be recorded on the .edf
%   file.
% * _sendTrigger_ - sends a trigger to be recorded both on the .bdf file
%   and on the .edf file.
% * _pixels2vAngles_ - converts pixels units to visual degrees units.
% * _vAngles2pixels_ - converts visual degrees units to pixels units.
% * _defineTextFormat_ - defines psychtoolbox's text format and text size.
% * _drawImageInstructions_ - displays a .png image on full screen.
% * _pngFileToTex_ - load a .png file from a file path and create a texture
%   out of it.
% * _displayTimedTextures_ - displays textures for a set amount of time.
% * _drawFixationCircleWithAnulous_ - calls psychtoolbox's _DrawTextures_
%   for two concentric filled circles in the middle of the screen (does
%   not flip).
% * _drawFixationCross_ - calls psychtoolbox's _DrawLines_
%   for a fixation cross in the middle of the screen (does not flip).
% * _drawFixationCrossAtPos_ - calls psychtoolbox's _DrawLines_ for a fixation 
%   at a given location (does not flip).
% * _sampleGazeCoords_ - samples the gaze's x and y coordinates
% * _testFixationBreaking_ - tests whether the gaze's distance from the
%   center of the screen exceeds the distance specified in the GUI as
%   the maximum allowed.
% * _checkPauseReq_ - checks whether [esc] is pressed and pauses the
%       experiment if it is, while showing a menu screen.
%       can show a fixation cross during the display and can monitor [esc]
%       key press and fixation breaks.
% * _KbCheckRB_ - checks whether a response box key is pressed.
%%

% first and foremost:
close all;
% sca;

%% Experiment Definitions
%experiment name
EXPERIMENT_NAME= 'exp';

%folder constants
GUI_XML_FILE= fullfile('guiXML.xml');
MSGS_FOLDER= fullfile('resources','instructions');
QUESTIONS_FOLDER = fullfile('resources','questions');
EXPDATA_SAVE_FOLDER= fullfile('resources','data files', 'behavioral data');
WORKSPACE_SAVE_FOLDER= fullfile('resources','data files', 'data pileups');
EDF_SAVE_FOLDER= fullfile('resources','data files', 'eye tracking data');

%lab room setup parameters definitions
SUBJECT_DISTANCE_FROM_SCREEN= [];
SCREEN_WIDTH= [];
SCREEN_HEIGHT= [];
GAMMA_TABLE_FULL_PATH= [];

%experiment's parameters definitions - EDIT
LAB_ROOM= [];
BACKGROUND_COLOR= [];
SUBJECT_NUMBER= [];
SUBJECT_AGE= [];
SUBJECT_GENDER= [];
BLOCKS_NR_MULTIPLIER= [];
TRIALS_NR_MULTIPLIER= [];
FIXATION_CROSS_ARMS_LEN_IN_VANGLES= [];
FIXATION_CROSS_ARMS_WIDTH_IN_VANGLES= [];
FIXATION_CROSS_COLOR= [];
START_WITH = [];
RESPONSE_TIME_ALLOWED= [];
POST_RESPONSE_DELAY= [];
FORCE_FIXATION= [];
POST_FIXATION_BREAK_DELAY= [];
MAX_GAZE_DIST_FROM_CENTER_IN_VANGLES= [];
EYE_TRACKING_METHOD= [];
EEG= [];
DEBUG= [];
TIME_WAITING_AT_THE_BEGINGING_OF_THE_TRIAL = 0;
TIME_FOR_FIXATION = 1;
NUMBER_OF_MSG_INVALID_KEY_TYPED = 7;
LEFT = 0;
INVALID_KEYBOARD_PRESSED = -1;
RIGHT = 1;
DOWN = 2;
ESC = 9;
NUMBER_OF_BLOCKS = 2;
BLOCKS_NR = NUMBER_OF_BLOCKS;
PATH_TO_PICS = char('resources\pics\');
NUMBER_OF_PICS = 60;

NUMBER_OF_TRIALS_PER_BLOCK = 3;

%experiment's parameters definitions - not included in the gui
GUI_BACKGROUND_COLOR= [0.8 0.8 0.8];
EXPDATA_SAVE_FILE_NAME_PREFIX= 'expdata';
EXPDATA_SAVE_FILE_NAME_SUFFIX= [];
WORKSPACE_SAVE_FILE_NAME_PREFIX= 'pileup';
WORKSPACE_SAVE_FILE_NAME_SUFFIX= [];
EDF_FILE_NAME_PREFIX = 's';
EDF_FILE_NAME_SUFFIX= [];
EDF_TEMP_FILE_NAME_PREFIX= 'eye';
GAZE_SAMPLES_FOR_FIXATION_BREAKING_VERDICT= 10;
INEXP_TEXT_COLOR= [];
INEXP_FONT_SZ = 20;
ABC_VEC = 'abcdefghijklmnopqrstuvwxyz';

function [level_value, staircaser_side]= staircaseFunc(level, staircaser_side)
    staircaser_side_i= (staircaser_side==ENUM_SIDE_RIGHT) + 1;
    level_value= GABOR_INITIAL_OPACITY(staircaser_side)*STAIRCASER_FUNC_DECLINE_RATE.^( STAIRCASER_FUNC_RESOLUTION*(1 - (level-STAIRCASER_FUNC_TRANSLATION(staircaser_side_i))) );
        
    if level_value>GABOR_MAXIMAL_OPACITY
    	level_value= GABOR_MAXIMAL_OPACITY;
    	STAIRCASER_FUNC_TRANSLATION(staircaser_side_i)= STAIRCASER_FUNC_TRANSLATION(staircaser_side_i)-1;
    end
end

%psychtoolbox keyboard constants
KBOARD_CODE_A = 65; KBOARD_CODE_B = 66; KBOARD_CODE_C = 67; KBOARD_CODE_D = 68; KBOARD_CODE_E = 69; KBOARD_CODE_F = 70;
KBOARD_CODE_G = 71; KBOARD_CODE_H = 72; KBOARD_CODE_I = 73; KBOARD_CODE_J = 74; KBOARD_CODE_K = 75; KBOARD_CODE_L = 76; 
KBOARD_CODE_M = 77; KBOARD_CODE_N = 78; KBOARD_CODE_O = 79; KBOARD_CODE_P = 80; KBOARD_CODE_Q = 81; KBOARD_CODE_R = 82;
KBOARD_CODE_S = 83; KBOARD_CODE_T = 84; KBOARD_CODE_U = 85; KBOARD_CODE_V = 86; KBOARD_CODE_W = 87; KBOARD_CODE_X = 88;
KBOARD_CODE_Y = 89; KBOARD_CODE_Z = 90;
KBOARD_CODE_ESC = 27; KBOARD_CODE_SPACE = 32; KBOARD_CODE_FRONT_SLASH= 191; 
KBOARD_CODE_LEFT=37; KBOARD_CODE_UP=38; KBOARD_CODE_RIGHT=39; KBOARD_CODE_DOWN=40;
KBOARD_CODE_0= 48; KBOARD_CODE_9= 57;
KBOARD_CODE_NUMPAD0= 96; KBOARD_CODE_NUMPAD9= 105;
KBOARD_CODE_SHIFT = 16;

%data record object
EXPDATA= [];

%experiment extra gear objects
IO_OBJ= [];
OUT_PORT= [];
OUT_FUNC= [];
IN_PORT= hex2dec('D011'); %on all labs computers
IN_FUNC= [];
EL_PARAMS= [];
FIXATION_MONITOR= [];

%triggers constants
PORT_SLEEP_CODE= 0;
BIOSEMI_CODE_START= 255;
BIOSEMI_CODE_END= 254;
TRIGGERS_RECORDING_STARTED= 66;
TRIGGERS_RECORDING_ENDED= 67;
TRIGGERS_START_BREAK= 68;
TRIGGERS_END_BREAK= 69;
TRIGGERS_EYE_TRACKER_CALIBRATION_STARTED= 99;
TRIGGERS_EYE_TRACKER_CALIBRATION_ENDED= 98;
TRIGGERS_FIXATION_BROKEN= 200;
TRIGGERS_START_TRAIL = 1;
TRIGGERS_SHOWING_PICTURE = 2;
TRIGGERS_PRESSING_KEYBOARD = 3;
TRIGGERS_END_TRIAL = 4;
TRIGGERS_ESC_PRESSED = 10;
TRIGGERS_INVALID_KEYBOARD_PRESSED = 11;


%is the experiment supposed to be running? (this flag is assigned a false
%value when the experiment is aborted, for instance by pressing esc and the 'y' key)
IS_EXP_GO= true;

%enumerables
ENUM_EYE_TRACKING_NO_TRACKING= ExperimentGuiBuilder.ENUM_EYE_TRACKING_NO_TRACKING;
ENUM_EYE_TRACKING_DUMMY_MODE= ExperimentGuiBuilder.ENUM_EYE_TRACKING_DUMMY_MODE;
ENUM_EYE_TRACKING_EYE_TRACKER= ExperimentGuiBuilder.ENUM_EYE_TRACKING_EYE_TRACKER;

%% GUI

% construct a gui building class object
gui_builder= ExperimentGuiBuilder(EXPERIMENT_NAME, GUI_BACKGROUND_COLOR, @runExpFunc, GUI_XML_FILE);

%PLACE YOUR UICONTROLS DEFINITIONS HERE
gui_builder.uicontrolRadios(4, 'Start with', {'left', 'right'}, {'left', 'right'},0);            

%fixation cross uicontrols
gui_builder.uicontrolReadNum(1, 'Fixation Cross Arms Length', ExperimentGuiBuilder.ENUM_VERIFY_POSITIVE_REAL);
gui_builder.uicontrolReadNum(2, 'Fixation Cross Arms Width', ExperimentGuiBuilder.ENUM_VERIFY_POSITIVE_REAL);
gui_builder.uicontrolReadColor(3, 'Fixation Cross Color');

 ...
     
%--------------------------------------

% display the gui
gui_builder.show();
    
%the [run experiment] callback
function runExpFunc(~, ~)   
    %extract the experiment parameters values from the gui's uicontrols
    common_params_values= gui_builder.getCommonParamsValues();
    LAB_ROOM= common_params_values{1}{1};
    SUBJECT_DISTANCE_FROM_SCREEN= common_params_values{1}{2};
    SCREEN_WIDTH= common_params_values{1}{3}; 
    SCREEN_HEIGHT= common_params_values{1}{4};
    GAMMA_TABLE_FULL_PATH= common_params_values{1}{5};
    SUBJECT_NUMBER= common_params_values{2};
    SUBJECT_AGE= common_params_values{3};
    SUBJECT_GENDER= common_params_values{4};
    BLOCKS_NR_MULTIPLIER= common_params_values{5};
    TRIALS_NR_MULTIPLIER= common_params_values{6};
    RESPONSE_TIME_ALLOWED= common_params_values{7};
    POST_RESPONSE_DELAY= common_params_values{8};
    FORCE_FIXATION= common_params_values{9};
    POST_FIXATION_BREAK_DELAY= common_params_values{10};
    MAX_GAZE_DIST_FROM_CENTER_IN_VANGLES= common_params_values{11};
    EYE_TRACKING_METHOD= common_params_values{12};
    EEG= common_params_values{13};
    BACKGROUND_COLOR= common_params_values{14};
    INEXP_TEXT_COLOR= 1 - round(BACKGROUND_COLOR);
    DEBUG= common_params_values{15};
    
    curr_exp_params_values= gui_builder.getCurrExpParamsValues();
    FIXATION_CROSS_ARMS_LEN_IN_VANGLES= curr_exp_params_values{1};
    FIXATION_CROSS_ARMS_WIDTH_IN_VANGLES= curr_exp_params_values{2};
    FIXATION_CROSS_COLOR= curr_exp_params_values{3}; 
    START_WITH = curr_exp_params_values{4}; 
    
    [is_file_unique, user_response]= verifyFileUniqueness(fullfile(EXPDATA_SAVE_FOLDER, [EXPDATA_SAVE_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), EXPDATA_SAVE_FILE_NAME_SUFFIX, '.mat']));
    if ~is_file_unique && ~strcmp(user_response,'Overwrite')
        if strcmp(user_response,'Duplicate')
            EXPDATA_SAVE_FILE_NAME_SUFFIX= [EXPDATA_SAVE_FILE_NAME_SUFFIX, annotateFileDuplication(fullfile(EXPDATA_SAVE_FOLDER, [EXPDATA_SAVE_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), EXPDATA_SAVE_FILE_NAME_SUFFIX]), '.mat')];
        else %user_response=='Cancel'
            return;
        end
    end

    [is_file_unique, user_response]= verifyFileUniqueness(fullfile(EDF_SAVE_FOLDER, [EDF_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), EDF_FILE_NAME_SUFFIX, '.edf']));
    if ~is_file_unique && ~strcmp(user_response,'Overwrite')
        if strcmp(user_response,'Duplicate')
            EDF_FILE_NAME_SUFFIX= [EDF_FILE_NAME_SUFFIX, annotateFileDuplication(fullfile(EDF_FILE_SAVE_FOLDER, [EDF_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), EDF_FILE_NAME_SUFFIX]), '.edf')];
        else %user_response=='Cancel'
            return;
        end
    end
    
    %close the gui
    gui_builder.close();
    
    %run the experiment
    runExp();
    
    function annotation= annotateFileDuplication(file_name_without_ext, file_ext)
        does_file_exist= exist([file_name_without_ext, file_ext], 'file');
        duplicates_nr= 0;
        annotation= [];
        while (does_file_exist)
            duplicates_nr= duplicates_nr + 1;
            annotation= [' - duplicate ', num2str(duplicates_nr)];
            does_file_exist= exist([file_name_without_ext, annotation, file_ext],'file');
        end
    end
        
    function [is_file_unique, user_response]= verifyFileUniqueness(file_name)        
        user_response= [];
        if exist(file_name,'file')
            is_file_unique= false;
            user_response = questdlg(['File "' file_name '" already exists. How to proceed?'],'Confirm save file name','Overwrite','Duplicate','Cancel','Cancel');            
        else
            is_file_unique= true;
        end
    end
end
    
%% The Experiment Code
function runExp()        
    Priority(2);
    try 

    %1. start psychtoolbox and save screen variables as globals
    [window, window_rect]= turnOnPTBView();
    [window_center_x, window_center_y]= RectCenter(window_rect);
    window_center= [window_center_x, window_center_y];
    fps = Screen('FrameRate', window);
    ifi = Screen('GetFlipInterval', window);
    waitframes= 1;

    %convert globals' units
    FIXATION_CROSS_ARMS_LEN= vAngles2pixels(FIXATION_CROSS_ARMS_LEN_IN_VANGLES);
    FIXATION_CROSS_ARMS_WIDTH= vAngles2pixels(FIXATION_CROSS_ARMS_WIDTH_IN_VANGLES);    
    MAX_GAZE_DIST_FROM_CENTER= round(vAngles2pixels(MAX_GAZE_DIST_FROM_CENTER_IN_VANGLES));
    
    %2. initialize the biosemi and the eye tracker    
    initializeGear();

    %3. load stuff from files - EDIT
    msgs= scanMessages();
    [texes,dims]= loadResources();                
    NUMBER_OF_PICS = length(texes);       
    %4. randomize experiment's conditions - EDIT      
    [conditions_mat]= randomizeConditions();
    
    %5. define experiment record variables - EDIT
    initializeDataRecord();
    
    %6. start running the experiment - EDIT
    trial_overall_i = runBlocks(conditions_mat);

    %7. close everything nicely...
    terminateExp();

    catch exception
       if DEBUG
           Screen('CloseAll');       
           commandwindow;
           rethrow(exception);
       end

       terminateExp();
       disp(exception.message);
       for call_depth= 1:length(exception.stack)
          disp(exception.stack(call_depth));
       end
    end


    % FUNCTIONS IMPLEMENTATIONS
    % stage 1
    function [window, window_rect]= turnOnPTBView()                          
        PsychDefaultSetup(2);
        screens = Screen('Screens');
        Screen('Preference', 'ConserveVRAM', 64);
        screen_i = max(screens);
        if DEBUG
            Screen('Preference', 'SkipSyncTests', 1); 
            ShowCursor;            
        else
            Screen('Preference', 'SkipSyncTests', 0);
            HideCursor;
        end
%         Screen('Preference','SkipSyncTests', 1);
%         Screen('Preference','VisualDebugLevel', 0);
        [window, window_rect] = PsychImaging('OpenWindow', screen_i, BACKGROUND_COLOR);
        Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');        
        Screen('Preference', 'VisualDebugLevel', 3);            
        Screen('Preference', 'TextEncodingLocale', 'Windows-1244'); 
        if ~DEBUG && ~isempty(GAMMA_TABLE_FULL_PATH)                                   
            gamme_table= load(GAMMA_TABLE_FULL_PATH);
            Screen('LoadNormalizedGammaTable', window, gamme_table.gammaTable*[1 1 1]);            
        end        
    end

    % stage 2
    function initializeGear()
        if EYE_TRACKING_METHOD==ENUM_EYE_TRACKING_NO_TRACKING && ~EEG                
            return;
        else
            if LAB_ROOM==ExperimentGuiBuilder.ENUM_LAB1                    
                [IO_OBJ, OUT_PORT]=init_bio;
                IN_FUNC= @() io64(IO_OBJ,IN_PORT);
                OUT_FUNC= @(out_code) io64(IO_OBJ,OUT_PORT,out_code);
            elseif LAB_ROOM==ExperimentGuiBuilder.ENUM_LAB2
                IO_OBJ= io64();
                status= io64(IO_OBJ);
                if status~=0
                    disp('io64 failed');
                end

                IN_FUNC= @() io64(IO_OBJ,IN_PORT);
            end

            if EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING
                %Initalize eyetracker
                disp('Initizlizing Eye Tracker...');

                % Provide Eyelink with details about the graphics environment
                % and perform some initializations. The information is returned
                % in a structure that also contains useful defaults
                % and control codes (e.g. tracker state bit and Eyelink key values).
                EL_PARAMS= EyelinkInitDefaults(window);
                if ~EyelinkInit(EYE_TRACKING_METHOD==ENUM_EYE_TRACKING_DUMMY_MODE, 1)
                    terminateExp();
                    return;
                end

                [~ ,vs]=Eyelink('GetTrackerVersion');
                fprintf('Running experiment on a ''%s'' tracker.\n', vs );

                % make sure that we get gaze data from the Eyelink
                Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

                % open file to record data to
                status = Eyelink('openfile', [EDF_TEMP_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), '.edf']);
                if status ~= 0
                    disp(['Error opening eyelink file: error code ' num2str(status) '.']);
                    terminateExp();
                    return;
                end

                %assign preferences values
                elSetup(window_rect(3),window_rect(4));

                %start recording eyetracker data
                Eyelink('StartRecording');
                disp('start recording');
                if EYE_TRACKING_METHOD==ENUM_EYE_TRACKING_EYE_TRACKER
                    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
                    if eye_used == EL_PARAMS.BINOCULAR; % if both eyes are tracked
                        eye_used = EL_PARAMS.RIGHT_EYE; % use right eye
                    end
                    disp(['Eye used: ' num2str(eye_used)]);
                end

                %construct a fixation monitor class object
                FIXATION_MONITOR= FixationMonitor(EL_PARAMS, MAX_GAZE_DIST_FROM_CENTER, GAZE_SAMPLES_FOR_FIXATION_BREAKING_VERDICT);
            end

            if LAB_ROOM==ExperimentGuiBuilder.ENUM_LAB1 && EEG
                sendTrigger(PORT_SLEEP_CODE);                   

                %start recording eeg data and send a synchronization trigger
                sendTrigger(BIOSEMI_CODE_START);
                WaitSecs(0.2);                                        
                sendTrigger(TRIGGERS_RECORDING_STARTED);
                WaitSecs(0.2);                    
                sendTrigger(TRIGGERS_RECORDING_STARTED);                    
                WaitSecs(0.2);
                sendTrigger(TRIGGERS_RECORDING_STARTED);
                WaitSecs(0.2);
            end
        end
    end 

    % stage 3
    function msgs= scanMessages()
        msgs= loadImagesFromFolder(MSGS_FOLDER,'png');
        msgs= [msgs, loadImagesFromFolder(MSGS_FOLDER,'jpg')];
    end
    function questions= scanQuestions()
        msgs= loadImagesFromFolder(QUESTIONS_FOLDER,'png');
        msgs= [msgs, loadImagesFromFolder(QUESTIONS_FOLDER,'jpg')];
    end

    function [texes,dims]= loadResources()
        [texes , dims]= loadTexesFromFolder(PATH_TO_PICS, window, 'jpg');
        
    end                

    % stage 4
    function initializeDataRecord()
        EXPDATA.info.general_info.session_time = datestr(now);
        EXPDATA.info.general_info.experiment_duration= [];
        EXPDATA.info.general_info.experiment_net_duration= [];

        EXPDATA.info.subject_info.subject_number = SUBJECT_NUMBER;
        EXPDATA.info.subject_info.subject_gender = SUBJECT_GENDER;
        EXPDATA.info.subject_info.subject_age = SUBJECT_AGE;

        EXPDATA.info.lab_setup.subject_distance_from_screen_in_cm= SUBJECT_DISTANCE_FROM_SCREEN;
        EXPDATA.info.lab_setup.screen_width_in_cm= SCREEN_WIDTH;
        EXPDATA.info.lab_setup.screen_width_in_pixels= window_rect(3);
        EXPDATA.info.lab_setup.screen_width_in_visual_degrees= pixels2vAngles(window_rect(3));
        EXPDATA.info.lab_setup.screen_height_in_cm= SCREEN_HEIGHT;
        EXPDATA.info.lab_setup.screen_height_in_pixels= window_rect(4);
        EXPDATA.info.lab_setup.screen_height_in_visual_degrees= pixels2vAngles(window_rect(4));
        EXPDATA.info.lab_setup.pixels_per_vdegree= EXPDATA.info.lab_setup.screen_width_in_pixels/EXPDATA.info.lab_setup.screen_width_in_visual_degrees;                        
        EXPDATA.info.lab_setup.FPS= fps;
        %pictures parameters
        EXPDATA.info.experiment_parameters.time_limit_for_a_response= RESPONSE_TIME_ALLOWED;            

        
        
        
        for trial_i= 1:(NUMBER_OF_TRIALS_PER_BLOCK*BLOCKS_NR)
            EXPDATA.trials(trial_i).block_number = [];
            EXPDATA.trials(trial_i).trial_number = [];                
            EXPDATA.trials(trial_i). trial_duration= [];
            EXPDATA.trials(trial_i).response = [];
            EXPDATA.trials(trial_i).left_picture_rank = [];
            EXPDATA.trials(trial_i).right_picture_rank = [];
            
        end

        for block_i= 1:BLOCKS_NR

        end
    end

    % stage 5
    % reminder -> loop through the trials if the randomizing functions dont
    % fit (dont use matlab vector indexing crap)
    %conditions_mat columns
    %----------------------
    %1: ... 
    %2: ...
    %3: ...
    % ...
    function [conditions_mat]= randomizeConditions()
        TOTAL_TRIALS_NR = NUMBER_OF_BLOCKS * NUMBER_OF_TRIALS_PER_BLOCK;
        conditions_mat = NaN(TOTAL_TRIALS_NR, 2);
        for trial_i = 1 : TOTAL_TRIALS_NR
            %random for the exp and save it to the condition matrix
            myFirstPic = randi(NUMBER_OF_PICS);
            myPicsWithoutFirstChosenOne = setdiff(1:NUMBER_OF_PICS, myFirstPic);
            mySecondPic = myPicsWithoutFirstChosenOne(ceil(numel(myPicsWithoutFirstChosenOne) * rand)); 
            conditions_mat(trial_i,1) = myFirstPic;
            conditions_mat(trial_i,2) = mySecondPic;
        end
        save('conditions_mat.mat', 'conditions_mat');
    end

    % stage 6
    function trial_overall_i = runBlocks(conditions_mat)
        %display the openning instructions screen
        drawImageInstructions(msgs{1});
        exp_start_vbl= KbWait([],2);
        %start the blocks loop
        total_experiment_pauses_duration= 0;
        for block_i = 1:BLOCKS_NR  
            %display instr uctions
            drawImageInstructions(msgs{2});
            KbWait([],2);
            if block_i == 1
                drawImageInstructions(msgs{6});
                KbWait([],2);
            elseif block_i ~= 1 && strcmp(START_WITH,'right')
                drawImageInstructions(msgs{9});
                KbWait([],2);
            else
                drawImageInstructions(msgs{9});
                KbWait([],2); 
            end
            echo(TRIGGERS_START_BREAK, num2str(TRIGGERS_START_BREAK)); 
            prev_font_sz = Screen('TextSize', window, INEXP_FONT_SZ);
            DrawFormattedText(window,'escape pressed... ',window_center_x-100, window_center_y, INEXP_TEXT_COLOR);
            DrawFormattedText(window, 'p -> proceed, c -> calibrate eye tracker, q -> quit experiment',window_center_x-400, window_center_y+40,INEXP_TEXT_COLOR);
            Screen('Flip', window);
            Screen('TextSize', window, prev_font_sz);
            while (1)
                [~, key_codes, ~]= KbWait([],2);
                key_code= find(key_codes, 1);
                if key_code == KBOARD_CODE_P
                    break;
                elseif key_code == KBOARD_CODE_C
                    calibrateEyeTracker();
                    break;
                elseif key_code == KBOARD_CODE_Q
                    IS_EXP_GO= false;
                    break;
                end
            end         
            Screen('Flip', window);
            echo(TRIGGERS_END_BREAK, num2str(TRIGGERS_END_BREAK));
            %compute the index of the first trial of the current block
            trials_nr_on_curr_block = (block_i * NUMBER_OF_TRIALS_PER_BLOCK) - NUMBER_OF_TRIALS_PER_BLOCK + 1;
            for trial_inside_block_i= 1:NUMBER_OF_TRIALS_PER_BLOCK                             
                trial_overall_i= trials_nr_on_curr_block+trial_inside_block_i-1;
                EXPDATA.trials(trial_overall_i).block_number= block_i;
                EXPDATA.trials(trial_overall_i).trial_number= trial_overall_i;
                FIXATION_CROSS_ARMS_LEN = vAngles2pixels(FIXATION_CROSS_ARMS_LEN_IN_VANGLES);
                FIXATION_CROSS_ARMS_WIDTH = vAngles2pixels(FIXATION_CROSS_ARMS_WIDTH_IN_VANGLES);
                curr_trial_pause_duration = 0;
                trial_vector= [conditions_mat(trial_overall_i,:),block_i];
                [trial_start_vbl, trial_end_vbl,subject_response, picRank] = runTrial(trial_vector);
                EXPDATA.trials(trial_overall_i).response = subject_response;
                disp('in run block');
                disp(picRank);
                EXPDATA.trials(trial_overall_i).left_picture_rank = picRank;
                EXPDATA.trials(trial_overall_i).right_picture_rank = picRank;
                EXPDATA.trials(trial_overall_i).trial_duration = trial_end_vbl-trial_start_vbl;
                total_experiment_pauses_duration= total_experiment_pauses_duration + curr_trial_pause_duration;
                if (~IS_EXP_GO)
                    %EXPDATA.info.general_info.experiment_
                    duration= trial_end_vbl - exp_start_vbl;
                    break;
                end
                EXPDATA.trials(trial_overall_i).trial_duration= trial_end_vbl - trial_start_vbl;
            end

            if (~IS_EXP_GO)
                break;
            end 
            
            if block_i<BLOCKS_NR
                drawImageInstructions(msgs{3});
                KbWait([],2);
            end
        end                                            

        if (~IS_EXP_GO)
            return;
        end
        
        %display the screen for the end of the experiment
        exp_end_vbl= drawImageInstructions(msgs{5});    
        EXPDATA.info.general_info.experiment_duration= exp_end_vbl - exp_start_vbl;
        EXPDATA.info.general_info.experiment_net_duration= exp_end_vbl - exp_start_vbl- total_experiment_pauses_duration;
        KbWait([],2);                                              

        % function runTrial - run a single trial sequence
        % ---------------------------------------------------------------------------------------------------
        % input:
        %   * trial_params: a row from conditions_mat.
        %   * trial_overall_i: the index of current trial (relative to
        %                      the entire experiment.
        %   * staircaser: an instance of Staircaser class
        % 
        % output:
        %   * trial_start_vbl= the onset time of the first stimulus.
        %   * trial_end_vbl= the end time of the last stimulus' display loop.
        %   * response_result= true if the response was correct and false if it was not. 
        %   * pause_dur= the total time spent on the pause screen during the trial.
        %   * staircaser_updated= the updated version of the Staircaser object.
        %   * was_response_made_too_early= true if the subject made a response too early and false otherwise.
        %   * was_fixation_broken= true if the subject broke fixation and false otherwise.
        % ---------------------------------------------------------------------------------------------------
        function [trial_start_vbl, trial_end_vbl, subject_response, picRank]= runTrial(trial_params)
            sendTrigger(TRIGGERS_START_TRAIL);
            drawFixationCross(FIXATION_CROSS_ARMS_LEN, FIXATION_CROSS_ARMS_WIDTH, FIXATION_CROSS_COLOR);
            trial_start_vbl = Screen('Flip', window);
            WaitSecs(TIME_FOR_FIXATION);
            picLeft = trial_params(1);
            picRight = trial_params(2);
            blockNum = trial_params(3);
            switch blockNum
                case 1
                    Screen('DrawTextures', window, [texes{picLeft}; texes{picRight}],[],[200 100 760 940;1150 100 1710 940]');
                    EXPDATA.trials(trial_overall_i).left_picture = trial_params(1);
                    EXPDATA.trials(trial_overall_i).right_picture = trial_params(2);
                case 2
                    Screen('DrawTextures', window, [texes{picLeft}],[],[675 100 1225 940]);
                    EXPDATA.trials(trial_overall_i).left_picture = trial_params(1);
                    EXPDATA.trials(trial_overall_i).right_picture = trial_params(1);
            end
            Screen('Flip', window);
            sendTrigger(TRIGGERS_SHOWING_PICTURE);
            WaitSecs(TIME_WAITING_AT_THE_BEGINGING_OF_THE_TRIAL);
            % Down = Abstain
            while (1)
                [keyIsDown, secs, keyCode] = KbCheck();
                if (keyIsDown)
                    trial_end_vbl = secs;
                    pressed_key_code = find(keyCode, 1);
                    if blockNum ~= 1 && (pressed_key_code ~= KBOARD_CODE_ESC)
                        [picRank] = getRankFromUser(window, FIXATION_CROSS_COLOR, msgs);
                        disp('in run trial');
                        disp(picRank);
                        subject_response = -1;
                        sendTrigger(TRIGGERS_PRESSING_KEYBOARD);
                        sendTrigger(TRIGGERS_END_TRIAL);
                        return;
                    end
                    if (pressed_key_code == KBOARD_CODE_LEFT)
                        subject_response = LEFT;
                        sendTrigger(TRIGGERS_PRESSING_KEYBOARD);
                        sendTrigger(TRIGGERS_END_TRIAL);
                        picRank = NaN;
                        return;
                    elseif (pressed_key_code == KBOARD_CODE_RIGHT)
                        subject_response = RIGHT;
                        sendTrigger(TRIGGERS_PRESSING_KEYBOARD);
                        sendTrigger(TRIGGERS_END_TRIAL);
                        picRank = NaN;
                        return;
                    elseif (pressed_key_code == KBOARD_CODE_DOWN)
                        subject_response = DOWN;
                        sendTrigger(TRIGGERS_PRESSING_KEYBOARD);
                        sendTrigger(TRIGGERS_END_TRIAL);
                        picRank = NaN;
                        return;
                    elseif (pressed_key_code == KBOARD_CODE_ESC)
                        sendTrigger(TRIGGERS_ESC_PRESSED);
                        subject_response = ESC;
                        picRank = NaN;
                        echo(TRIGGERS_START_BREAK, num2str(TRIGGERS_START_BREAK)); 
                        prev_font_sz = Screen('TextSize', window, INEXP_FONT_SZ);
                        DrawFormattedText(window,'escape pressed... ',window_center_x-100, window_center_y, INEXP_TEXT_COLOR);
                        DrawFormattedText(window, 'p -> proceed, c -> calibrate eye tracker, q -> quit experiment',window_center_x-400, window_center_y+40,INEXP_TEXT_COLOR);
                        Screen('Flip', window);
                        Screen('TextSize', window, prev_font_sz);
                        while (1)
                            [~, key_codes, ~]= KbWait([],2);
                            key_code= find(key_codes, 1);
                            if key_code == KBOARD_CODE_P
                                break;
                            elseif key_code == KBOARD_CODE_C
                                calibrateEyeTracker();
                                break;
                            elseif key_code == KBOARD_CODE_Q
                                IS_EXP_GO= false;
                                break;
                            end
                        end         
                        Screen('Flip', window);
                        echo(TRIGGERS_END_BREAK, num2str(TRIGGERS_END_BREAK));
                        sendTrigger(TRIGGERS_END_TRIAL);
                        return;
                    else
                        subject_response = INVALID_KEYBOARD_PRESSED;
                        picRank = NaN;
                        sendTrigger(TRIGGERS_INVALID_KEYBOARD_PRESSED);
                        %change is after pressing wrong key want to stop
                        %the trail. right now if the ket board press was
                        %wrong the trial continues.
                        drawImageInstructions(msgs{NUMBER_OF_MSG_INVALID_KEY_TYPED});
                        KbWait([],2); 
                        sendTrigger(TRIGGERS_END_TRIAL);
                        return;
                    end
                end
                trial_end_vbl = secs;
            end  
        end
    end
    % stage 7
    %function runQuestions(questions,trial_overall_i)
    %write here the part of the political questions
    %   for trial_overall_i = trial_overall_i+1 : trial_overall_i + NUMBER_OF_QUESTIONS+1
    %       drawImageInstructions(questions{trial_overall_i});
    %        %here is the part that I should get input from the user and
    %        %then save it to the XepData
    %        subject_response = 'bla';
    %        EXPDATA.trials(trial_overall_i).part = 3;
    %        EXPDATA.trials(trial_overall_i).trial_number = trial_overall_i;
    %        EXPDATA.trials(trial_overall_i).response = subject_response;
    %        
    %    end
    %   
    %   
    %end
    % stage 8
    function terminateExp()
        saveData();

        %send a synchronization trigger
        if LAB_ROOM==ExperimentGuiBuilder.ENUM_LAB1 && EEG
            sendTrigger(TRIGGERS_RECORDING_ENDED);                
            WaitSecs(0.2);
            sendTrigger(TRIGGERS_RECORDING_ENDED);                
            WaitSecs(0.2);
            sendTrigger(TRIGGERS_RECORDING_ENDED);                
            WaitSecs(3);
        end

        %stop the eyetracker
        if EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING
            Eyelink('StopRecording');
            disp('stop recording');
        end

        %stop the biosemi recording 
        if EEG
            sendTrigger(BIOSEMI_CODE_END);
        end

        %save the eyetracker recording data
        if EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING
            % Retrieve Eyelink EDF file
            disp('Retrieving EDF file from eye-tracker.');
            Eyelink('CloseFile');
            stat = Eyelink('ReceiveFile',[EDF_TEMP_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), '.edf']);
            disp(['stat is ',num2str(stat)]);
            if stat ~= 0
                disp( ['Error in retrieving EDF file: ' ,fullfile(EDF_SAVE_FOLDER, [EDF_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), EDF_FILE_NAME_SUFFIX, '.edf'])] );
            end

            movefile([EDF_TEMP_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), '.edf'], fullfile(EDF_SAVE_FOLDER, [EDF_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), EDF_FILE_NAME_SUFFIX, '.edf']));                
            Eyelink('Shutdown');
        end 

        ShowCursor;
        Screen('CloseAll');

        % Give focus back to Matlab
        commandwindow;

        function saveData()
            %save data record
            save(fullfile(EXPDATA_SAVE_FOLDER, [EXPDATA_SAVE_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), EXPDATA_SAVE_FILE_NAME_SUFFIX]), 'EXPDATA');

            %save pileup;                
            save(fullfile(WORKSPACE_SAVE_FOLDER, [WORKSPACE_SAVE_FILE_NAME_PREFIX, num2str(SUBJECT_NUMBER), WORKSPACE_SAVE_FILE_NAME_SUFFIX]));                                                
        end
    end

    %% Miscelenious Utility Functions              
    function runCalibrationQuery()
        if (EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING)
            txt = 'Perform an eye-tracker calibration? Y/N';
            Screen('FillRect', window, BACKGROUND_COLOR);
            prev_font_sz = Screen('TextSize', window, INEXP_FONT_SZ);
            DrawFormattedText(window,txt,'center','center',INEXP_TEXT_COLOR,[],[],[],2);
            Screen('Flip', window);
            Screen('TextSize', window, prev_font_sz);
            while (1)
                [~,keyCodes] = KbWait;                    
                if find(keyCodes, 1) == KBOARD_CODE_Y
                    run_calibrate = true;
                    break;
                elseif find(keyCodes, 1) == KBOARD_CODE_N
                    run_calibrate = false;
                    break;
                end
            end

            if (run_calibrate)
                calibrateEyeTracker();
            end
        end
    end

    function calibrateEyeTracker()
        if (EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING)                
            %echo(TRIGGERS_EYE_TRACKER_CALIBRATION_STARTED, num2str(TRIGGERS_EYE_TRACKER_CALIBRATION_STARTED));                

            EyelinkDoTrackerSetup(EL_PARAMS);
            [~, msg_str]= Eyelink('CalMessage');
            disp(' ');
            disp('calibration statistics:');
            disp('----------------------');
            disp(msg_str);

            EyelinkDoDriftCorrection(EL_PARAMS);
            [~, msg_str]= Eyelink('CalMessage');
            disp(' ');
            disp('drift correction statistics:');
            disp('----------------------');
            disp(msg_str);

            %echo(TRIGGERS_EYE_TRACKER_CALIBRATION_ENDED, num2str(TRIGGERS_EYE_TRACKER_CALIBRATION_ENDED));
            Screen('FillRect', window, BACKGROUND_COLOR);
            Eyelink('StartRecording');
            disp('start recording');
        end
    end                        

    function echo(trigger, eyelink_msg, varargin) 
        if LAB_ROOM==ExperimentGuiBuilder.ENUM_LAB1 && EEG
            sendTrigger(trigger);
        elseif (LAB_ROOM==ExperimentGuiBuilder.ENUM_LAB1 || LAB_ROOM==ExperimentGuiBuilder.ENUM_LAB2 || LAB_ROOM==ExperimentGuiBuilder.ENUM_LAB3) && EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING
            sendEyelinkMsg(eyelink_msg, varargin);
        end
    end

    function sendEyelinkMsg(msg, varargin)
        if EYE_TRACKING_METHOD==ENUM_EYE_TRACKING_NO_TRACKING
            return;
        end

        Eyelink('message', msg, varargin);
    end

    function sendTrigger(code, wait_secs)
        if LAB_ROOM~=ExperimentGuiBuilder.ENUM_LAB1 || ~EEG
            return;
        end  

        OUT_FUNC(code);
        if nargin==1
            WaitSecs(.005);
        else
            WaitSecs(wait_secs);
        end

        OUT_FUNC(PORT_SLEEP_CODE);            
    end

    function v_angle= pixels2vAngles(pixels)
        v_angles= [];
        window_size= Screen('WindowSize', window);
        cm_per_pixels= SCREEN_WIDTH/window_size(1);
        for pixel_i= 1:numel(pixels)                        
            v_angle= [v_angles, rad2deg(2*atan(((pixels(pixel_i)/2)*cm_per_pixels)/SUBJECT_DISTANCE_FROM_SCREEN))];        
        end
    end

    function pixels= vAngles2pixels(v_angles)
        pixels= [];
        window_size = Screen('WindowSize', window);
        pixels_per_cm= window_size(1)/SCREEN_WIDTH;
        for v_angle_i= 1:numel(v_angles)
            pixels= [pixels, 2*SUBJECT_DISTANCE_FROM_SCREEN*tan(deg2rad(v_angles(v_angle_i)/2))*pixels_per_cm];
        end
    end
    
    function pos= calcCenterStrPosBySz(str)
        if isempty(str)
            pos= window_center;
        else
            [str_bounds,~]= Screen('TextBounds', window, str, window_center_x, window_center_y); 
            %str_height= str_bounds(4);
            %str_len= Screen('TextSize',window)*96/72*numel(str);
            pos= round([window_center_x, window_center_y] - str_bounds([3,4])*0.5);      
        end
    end
    
    function defineTextFormat(text_size, text_font)
        Screen('TextSize', window, text_size);
        Screen('TextFont', window, text_font);
    end
    
    %load lines from a txt file. the file has to be encoded as Unicode.
    function words= loadUnicodeWordsFromFile(file)
        fid = fopen(file);        
        words= strsplit(native2unicode(fread(fid)', 'Unicode'), sprintf('\n'));
        words= cellfun(@strtrim, words, 'UniformOutput', false);                
        fclose(fid);
    end
    
    function ppa_handle = buildPsychPortAudioHandle(audio_file)
        [snd_data, snd_freq] = audioread(audio_file);
        snd_data= snd_data';       
        chans_nr = size(snd_data,1);
        if chans_nr < 2
            snd_data = [snd_data ; snd_data];
            chans_nr = 2;
        end
        
        try
            % Try with the 'freq'uency we wanted:
            ppa_handle = PsychPortAudio('Open',[], [], [], [], [], 50);
            %ppa_handle = PsychPortAudio('Open', [], [], 0, snd_freq, chans_nr);
        catch
            % Failed. Retry with default frequency as suggested by device:
            fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', snd_freq);
            fprintf('Sound may sound a bit out of tune, ...\n\n');
            psychlasterror('reset');
            
            ppa_handle = PsychPortAudio('Open', [], [], 0, [], chans_nr);
        end
                     
        PsychPortAudio('FillBuffer', ppa_handle, snd_data);          
    end
    
    function [picRank] = getRankFromUser(window, FIXATION_CROSS_COLOR, msgs)    
        text = 'What is the your rank (from 1 to 9) for this picture?  ';
        picRank = slideScale(window,text, window_rect, {'1', '9'} );
        picRank = round(picRank/25 );
        picRank = 5+picRank;
    end
    

    function instructions_laid_down_vbl= drawImageInstructions(img)
        tex= Screen('MakeTexture', window, img);        
        tex_rect= genRect(window_center, window_rect(3:4));
        Screen('DrawTextures', window, tex, [], tex_rect);
        instructions_laid_down_vbl= Screen('Flip', window);
    end

    function tex = pngFileToTex(file_path)
        [im(:,:,1:3),~,im(:,:,4)]= imread(file_path,'png');
        tex= Screen('MakeTexture', window, im);
    end

    function [textures_onset_vbl, pause_end_vbl, pause_duration_during_display, was_fixation_broken, was_key_pressed, vbl_of_last_retrace]= displayTimedTextures(show_fixation_cross, display_frames_nr, verify_fixation, verify_key_press, vbl_of_last_retrace, textures, texture_rects, texture_angs, texture_opacities, texture_colors, trigger, eyelink_msg)
        pause_duration_during_display= 0;
        was_fixation_broken= false;
        was_key_pressed= false;        
        is_curr_iteration_the_first= true;
        pause_end_vbl= -1;
        textures_onset_vbl= -1;
        ifi_end_vbl= -1;
        if display_frames_nr<=0
            return;
        end                
        elapsed_frames_nr= 0;
        ifi_start_vbl= vbl_of_last_retrace;
        %why (display_frames_nr-1): last frame is displayed during the first flip of
        %the next stimulus
        while (elapsed_frames_nr<display_frames_nr-1 && IS_EXP_GO)
            if show_fixation_cross
                drawFixationCross(FIXATION_CROSS_ARMS_LEN, FIXATION_CROSS_ARMS_WIDTH, FIXATION_CROSS_COLOR);
            end

            if (nargin>=7)
                for tex_i=1:numel(textures)
                    Screen('DrawTextures', window, textures{tex_i}, [], texture_rects{tex_i}, texture_angs{tex_i}, [], texture_opacities{tex_i}, texture_colors{tex_i});
                end
            end

            ifi_end_vbl= Screen('Flip', window, ifi_start_vbl + (waitframes - 0.5) * ifi);
            if (is_curr_iteration_the_first)
                textures_onset_vbl= ifi_end_vbl;
                if (nargin>=4 && numel(trigger)==1)
                    echo(trigger, eyelink_msg);
                end
                is_curr_iteration_the_first= false;
            else
                elapsed_frames_nr= elapsed_frames_nr + 1;
            end                

            if (verify_fixation)
                was_fixation_broken= testFixationBreaking(window_center, true);
                if (was_fixation_broken)
                    echo(TRIGGERS_FIXATION_BROKEN, num2str(TRIGGERS_FIXATION_BROKEN));
                    break;
                end
            end

            if (verify_key_press)
                [was_key_pressed , ~, ~]= KbCheckRB();
                if (was_key_pressed)
                    echo(TRIGGERS_SUBJECT_RESPONDED_TOO_EARLY, num2str(TRIGGERS_SUBJECT_RESPONDED_TOO_EARLY));                        
                    break;
                end
            end

            [pause_duration, pause_end_vbl]= checkPauseReq();
            if (pause_duration>0)
                pause_duration_during_display= pause_duration_during_display + pause_duration;
                ifi_start_vbl= pause_end_vbl;
            else
                ifi_start_vbl= ifi_end_vbl;
            end
        end

        vbl_of_last_retrace= ifi_end_vbl;
    end
    
    
    
%     function [textures_onset_vbl, pause_end_vbl, pause_duration_during_display, was_fixation_broken, was_key_pressed, vbl_of_last_retrace]= displayTimedTexturesBetter(show_fixation_cross, display_dur, verify_fixation, verify_key_press, vbl_of_last_retrace, textures, texture_rects, texture_angs, texture_opacities, texture_colors, trigger, eyelink_msg)
%         pause_duration_during_display= 0;
%         was_fixation_broken= false;
%         was_key_pressed= false;        
%         is_curr_iteration_the_first= true;
%         pause_end_vbl= -1;
%         textures_onset_vbl= -1;        
%         if display_dur<=0
%             return;
%         end
%         
%         ifi_end_vbl= drawStimuli(vbl_of_last_retrace);
%         display_frames_nr= floor(display_dur*fps);
%         elapsed_frames_nr= 0;        
%         %why (display_frames_nr-1): last frame is displayed during the first flip of
%         %the next stimulus                                
%         while (elapsed_frames_nr<=display_frames_nr-1 && IS_EXP_GO)            
%             if (is_curr_iteration_the_first)
%                 textures_onset_vbl= ifi_end_vbl;
%                 if (nargin>=4 && numel(trigger)==1)
%                     echo(trigger, eyelink_msg);
%                 end
%                 is_curr_iteration_the_first= false;
%             end                                           
%             
%             [pause_duration, pause_end_vbl]= checkPauseReq();
%             if (pause_duration>0)
%                 pause_duration_during_display= pause_duration_during_display + pause_duration;
%                 %stimuli were displayed during the flip for the pause screen
%                 elapsed_frames_nr= elapsed_frames_nr + 1;
%                 ifi_start_vbl= drawStimuli(pause_end_vbl);                
%             else
%                 ifi_start_vbl= ifi_end_vbl;
%             end
%             
%             if (verify_key_press)
%                 [was_key_pressed , ~, ~]= KbCheckRB();
%                 if (was_key_pressed)
%                     echo(TRIGGERS_SUBJECT_RESPONDED_TOO_EARLY, num2str(TRIGGERS_SUBJECT_RESPONDED_TOO_EARLY));                        
%                     break;
%                 end
%             end
%             
%             if (verify_fixation)
%                 was_fixation_broken= testFixationBreaking();
%                 if (was_fixation_broken)
%                     echo(TRIGGERS_FIXATION_BROKEN, num2str(TRIGGERS_FIXATION_BROKEN));
%                     break;
%                 end
%             end           
%                        
%             ifi_end_vbl= Screen('Flip', window, ifi_start_vbl + (waitframes - 0.5) * ifi, 1);
%             elapsed_frames_nr= elapsed_frames_nr + 1;
%         end
% 
%         vbl_of_last_retrace= ifi_end_vbl;
%         
%         function flip_end_vbl= drawStimuli(ifi_start_vbl)
%             if show_fixation_cross
%                 drawFixationCross(FIXATION_CROSS_ARMS_LEN, FIXATION_CROSS_ARMS_WIDTH, FIXATION_CROSS_COLOR);
%             end
% 
%             if (nargin>=7)
%                 for tex_i=1:numel(textures)
%                     Screen('DrawTextures', window, textures{tex_i}, [], texture_rects{tex_i}, texture_angs{tex_i}, [], texture_opacities{tex_i}, texture_colors{tex_i});
%                 end
%             end
% 
%             flip_end_vbl= Screen('Flip', window, ifi_start_vbl + (waitframes - 0.5) * ifi);
%         end
%     end            

    function drawFixationDot(diameter, color)
        drawFixationDotAtPos(window_center, diameter, color);
    end

    function drawFixationDotAtPos(pos, diameter, color)
        rect= genRect(pos, [diameter, diameter]);           
        Screen('FillOval', window, color, rect, 2*diameter);
    end

    function drawFixationCircleWithAnulous(circle_tex, inner_radius, inner_color, outer_radius, outer_color)
        inner_rect= genRect(window_center, 2*[inner_radius, inner_radius]);
        outer_rect= genRect(window_center, 2*[outer_radius, outer_radius]);
        rects= [outer_rect; inner_rect]';
        colors= [outer_color; inner_color]';
        Screen('DrawTextures', window, circle_tex, [], rects, [], [], [], colors);
    end

    function drawFixationCross(arms_len, arms_width, color)
        drawFixationCrossAtPos(window_center, arms_len, arms_width, color);
    end

    function drawFixationCrossAtPos(pos, arms_len, arms_width, color)
        cross_cords_x= [arms_len,-arms_len, 0, 0];
        cross_cords_y= [0, 0, arms_len, -arms_len];
        cross_cords= [cross_cords_x ; cross_cords_y];            
        Screen('DrawLines', window, cross_cords, arms_width, color, pos, 2);
    end

    function drawPlaceHolder(loc, overall_side, lines_width, lines_gap_ratio, color)        
        lines_coords= genPlaceHolderLinesMat(overall_side, lines_width, lines_gap_ratio);
        Screen('DrawLines', window, lines_coords', lines_width, color, loc-0.5*overall_side, 2);
    end
    
    function lines_coords = genPlaceHolderLinesMat(overall_side, lines_width, lines_gap_ratio)
        lines_lens= 0.5*overall_side*(1-lines_gap_ratio);
        lines_coords= [-0.5*lines_width, 0; lines_lens, 0;
                       overall_side-lines_lens, 0; overall_side+0.5*lines_width, 0;
                       overall_side, -0.5*lines_width; overall_side, lines_lens;
                       overall_side, overall_side-lines_lens; overall_side, overall_side+0.5*lines_width;
                       overall_side+0.5*lines_width, overall_side; overall_side-lines_lens, overall_side;
                       lines_lens, overall_side; -0.5*lines_width, overall_side;
                       0, overall_side+0.5*lines_width; 0, overall_side-lines_lens;
                       0, lines_lens; 0, -0.5*lines_width]';        
    end
    
    function drawOrientedHet(loc, overall_side, lines_width, color, rot)
        lines_coords = genOrientedHetLinesMat(overall_side, lines_width, rot);
        Screen('DrawLines', window, lines_coords, lines_width, color, loc-0.5*overall_side, 2);
    end
    
    function lines_coords = genOrientedHetLinesMat(overall_side, lines_width, rot)
        corner_coord = 0.5*(overall_side + lines_width);
        lines_coords= [-corner_coord, -corner_coord;
                        -corner_coord, corner_coord;
                        corner_coord, corner_coord;
                       corner_coord, -corner_coord]';
        rot_mat = [cos(rot) -sin(rot); sin(rot) cos(rot)];       
        lines_coords = rot_mat*lines_coords;                
    end        
    
    % gaze_coords -> 2 X 2 Matrix:
    % gaze_coords(1,:) -> left eye
    % gaze_coords(2,:) -> right eye
    % gaze_coords(:,1) -> x coordinates
    % gaze_coords(:,2) -> y coordinates
    % gaze_coords(?,:) == NaN if the corresponding eye is not available or if
    % there is missing data
    function [gaze_coords, sample_vbl]= sampleGazeCoords()
        gaze_coords= NaN(2,2);
        sample_vbl= [];
        if EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING
            eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
            if eye_used ~= -1 && Eyelink('NewFloatSampleAvailable') > 0
                evt= Eyelink('NewestFloatSample');   % get the sample in the form of an event structure
                sample_vbl= GetSecs();
                if (eye_used == EL_PARAMS.BINOCULAR || eye_used == EL_PARAMS.LEFT_EYE) && evt.gx(EL_PARAMS.LEFT_EYE+1)~=EL_PARAMS.MISSING_DATA && evt.gy(EL_PARAMS.LEFT_EYE+1)~=EL_PARAMS.MISSING_DATA
                    gaze_coords(1,:)= ceil([evt.gx(EL_PARAMS.LEFT_EYE+1), evt.gy(EL_PARAMS.LEFT_EYE+1)]);
                end
                
                if (eye_used == EL_PARAMS.BINOCULAR || eye_used == EL_PARAMS.RIGHT_EYE) && evt.gx(EL_PARAMS.RIGHT_EYE+1)~=EL_PARAMS.MISSING_DATA && evt.gy(EL_PARAMS.RIGHT_EYE+1)~=EL_PARAMS.MISSING_DATA
                    gaze_coords(2,:)= ceil([evt.gx(EL_PARAMS.RIGHT_EYE+1), evt.gy(EL_PARAMS.RIGHT_EYE+1)]);
                end
            end
        end
    end

    function was_fixation_broken= testFixationBreaking(fixation_loc, is_blinking_allowed)            
        was_fixation_broken= true;
        if (EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING)
            [FIXATION_MONITOR, res]= FIXATION_MONITOR.testFixationBreaking(fixation_loc, is_blinking_allowed);
            if res~=FIXATION_MONITOR.FIXATION_MONITOR_RESULT_IS_BREAKING
                was_fixation_broken= false;
            end
        end
    end

    function [pause_duration, pause_end_vbl]= checkPauseReq()
        pause_duration= 0;
        pause_end_vbl= -1;
        [keyIsDown, pause_start_vbl, keyCode, ~]= KbCheck;
        if (keyIsDown)                
            if find(keyCode, 1) == KBOARD_CODE_ESC                    
                echo(TRIGGERS_START_BREAK, num2str(TRIGGERS_START_BREAK)); 
                prev_font_sz = Screen('TextSize', window, INEXP_FONT_SZ);
                DrawFormattedText(window,'escape pressed... ',window_center_x-100, window_center_y, INEXP_TEXT_COLOR);
                DrawFormattedText(window, 'p -> proceed, c -> calibrate eye tracker, q -> quit experiment',window_center_x-400, window_center_y+40,INEXP_TEXT_COLOR);
                Screen('Flip', window, pause_start_vbl + (waitframes - 0.5) * ifi);
                Screen('TextSize', window, prev_font_sz);
                while (1)
                    [~, key_codes, ~]= KbWait([],2);
                    key_code= find(key_codes, 1);
                    if key_code == KBOARD_CODE_P
                        break;
                    elseif key_code == KBOARD_CODE_C
                        calibrateEyeTracker();
                        break;
                    elseif key_code == KBOARD_CODE_Q
                        IS_EXP_GO= false;
                        break;
                    end
                end

                pause_end_vbl= Screen('Flip', window);                    
                echo(TRIGGERS_END_BREAK, num2str(TRIGGERS_END_BREAK));                                         
                pause_duration= pause_end_vbl - pause_start_vbl;
            end
        end
    end

    % check if a key on the response box was pressed
    % output:
    %   * is_key_down: true if a key is down and false otherwise
    %   * key_pressed_vbl: the call time of kbCheckRB
    %   * key_codes: a 1x4 vector whose cells correspond to the buttons on the response key from left to right. 
    %                1 in a specific cell means its corresponding button on the response box is down, whereis 0 means
    %                the button is up.
    function [is_key_down, key_pressed_vbl, key_codes]= KbCheckRB()
        if EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING || EEG
            [is_key_down, key_pressed_vbl, key_codes]= KbCheckResponseBox(IN_FUNC);
        else
            is_key_down= false;
            key_pressed_vbl= -1;
            key_codes=- 1;
        end
    end
    
    function rads = deg2rad(degs)
        rads = degs*pi/180;
    end
    
    function degs = rad2deg(rads)
        degs = rads*180/pi;
    end

end
end

%         function startRecording()
%             if EEG
%                 sendTrigger(BIOSEMI_CODE_START);
%             end
%
%             if EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING
%                 runCalibrationQuery();
%             end
%
%             if EEG || EYE_TRACKING_METHOD~=ENUM_EYE_TRACKING_NO_TRACKING
%                 sendTrigger(66,0.5);
%                 sendTrigger(66,0.5);
%                 sendTrigger(66,0.5);
%                 WaitSecs(3);
%             end
%         end