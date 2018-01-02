function elSetup(winWidth,winHeight)
% SET UP TRACKER CONFIGURATION
%call this from any code after initialization (e.g. el=EyelinkInitDefaults(window);  ) 
%and opening file Eyelink('Openfile'....);
%based on EyelinkPictureCustomCalibration
%Roy Amit, fall 2014

% Setting the proper recording resolution, proper calibration type,
% as well as the data file content;

Eyelink('command', 'add_file_preamble_text ''my_exp_name''');
% This command is crucial to map the gaze positions from the tracker to
% screen pixel positions to determine fixation
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
% set calibration type.
Eyelink('command', 'calibration_type = HV9');
Eyelink('command', 'generate_default_targets = YES');
% set parser (conservative saccade thresholds)
Eyelink('command', 'saccade_velocity_threshold = 35');
Eyelink('command', 'saccade_acceleration_threshold = 9500');
% set EDF file contents
% 5.1 retrieve tracker version and tracker software version
[v,vs] = Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs );
vsn = regexp(vs,'\d','match');

if v == 3 && str2double(vsn{1}) == 4 % if EL 1000 and tracker version 4.xx
    
    % remote mode possible add HTARGET ( head target)
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET');
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
else
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end
% allow to use the big button on the eyelink gamepad to accept the
% calibration/drift correction target
Eyelink('command', 'button_function 5 "accept_target_fixation"');

if v == 3
    % set pupil Tracking model in camera setup screen
    % no = centroid. yes = ellipse
    Eyelink('command', 'use_ellipse_fitter = no');
    % set sample rate in camera setup screen
    Eyelink('command', 'sample_rate = %d',1000);
end

[result,reply]=Eyelink('ReadFromTracker','elcl_select_configuration');
%illumintaion powre\
Eyelink('command', 'elcl_tt_power = %d',2);

[result, reply]=Eyelink('ReadFromTracker','enable_automatic_calibration');

if reply % reply = 1
    fprintf('Automatic sequencing ON');
else
    fprintf('Automatic sequencing OFF');
end

end