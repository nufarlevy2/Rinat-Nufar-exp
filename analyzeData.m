function analyzeData()
INVALID_EYE_COORD = -2^15;
DO_ANIMATE = 0;
MILLIS_PER_DRAW = 10;

% these define a segmentation
CONDS = {'111', '112', '121', '122', '131', '132', '141', '142'};
END_TRIAL_TRIGGER = '4';
% TODO: fill when the analysis seperates conditions
 function trigger = getTrialTrigger(curr_trial_behavioral_data)
    block_type = expdata.blocks(curr_trial_behavioral_data.block_number).block_type;
    if strcmp(curr_trial_behavioral_data.gabor_appearance_side, 'up') && strcmp(block_type, 'spatio')
        trigger = '111';
    elseif strcmp(curr_trial_behavioral_data.gabor_appearance_side, 'down') && strcmp(block_type, 'spatio')
        trigger = '112'
    elseif strcmp(curr_trial_behavioral_data.gabor_appearance_side, 'up') && strcmp(block_type, 'retino')
        trigger = '121'
    elseif strcmp(curr_trial_behavioral_data.gabor_appearance_side, 'down') && strcmp(block_type, 'retino')
        trigger = '122'
    elseif strcmp(curr_trial_behavioral_data.gabor_appearance_side, 'up') && strcmp(block_type, 'divided') ...
            && strcmp (curr_trial_behavioral_data.retinotopic_placeholder_side, 'down') % spatio target (up) divided condition
        trigger = '131'
    elseif strcmp(curr_trial_behavioral_data.gabor_appearance_side, 'down') && strcmp(block_type, 'divided')...
            && strcmp (curr_trial_behavioral_data.retinotopic_placeholder_side, 'up') % spatio target (down) divided condition
        trigger = '132'
    elseif strcmp(curr_trial_behavioral_data.gabor_appearance_side, 'up') && strcmp(block_type, 'divided')...
            && strcmp (curr_trial_behavioral_data.retinotopic_placeholder_side, 'up') % retino target (up) divided condition
        trigger = '141'
    elseif strcmp(curr_trial_behavioral_data.gabor_appearance_side, 'down') && strcmp(block_type, 'divided')...
            && strcmp (curr_trial_behavioral_data.retinotopic_placeholder_side, 'down') % retino target (down) divided condition
        trigger = '142'
    end
    
    if isempty(trigger)
        a = 1;
    end
end   

% define data folders names
DATA_FOLDER = fullfile('Data');
EYE_DATA_PATH = fullfile(DATA_FOLDER, 'EyeData');
BEHAVIORAL_DATA_PATH = fullfile(DATA_FOLDER, 'BehavioralData');
ANALYSIS_STRUCT_PATH = fullfile(DATA_FOLDER);
eye_data_files_struct = dir(fullfile(EYE_DATA_PATH, 'rinatComplex*eye.mat'));
expdata_files_struct = dir(fullfile(BEHAVIORAL_DATA_PATH, 'rinatComplex*behavioral.mat'));
loaded_analysis_struct = load(fullfile(ANALYSIS_STRUCT_PATH, 'analysis_struct_fixations_new.mat'));
analysis_structs_cell_arr = loaded_analysis_struct.analysis_struct;
for subject_i= 1:numel(eye_data_files_struct)
    disp(['analyzing subject #', num2str(subject_i), ':']);
    disp('loading eye data.');
    % loading eye data file for current subject
    loaded_eye_tracking_data_mat_struct = load(fullfile(EYE_DATA_PATH, eye_data_files_struct(subject_i).name));
    eye_tracking_data_mat = loaded_eye_tracking_data_mat_struct.eye_tracking_data_mat;
    disp('loading expdata.');
    % loading expdata file for current subject
    loaded_expdata_files_struct = load(fullfile(BEHAVIORAL_DATA_PATH, expdata_files_struct(subject_i).name));
    expdata = loaded_expdata_files_struct.EXPDATA;
    
    % TODO: fill when the analysis seperates conditions
    analysis_struct_iterators = ones(1, numel(CONDS));
    % eyelink messages struct iterator
    msg_i = 1;
    for trial_i= 1:numel(expdata.trials)
        curr_trial_behavioral_data = expdata.trials(trial_i);
        % relevant for subject 102/202
        if isempty(curr_trial_behavioral_data.trial_duration) || strcmp(curr_trial_behavioral_data.subject_response, 'pursuit brake')
            continue;
        end
        
        % ----------------------------------
        % -----segmentizing next trial------
        % ----------------------------------
        % TODO: relevant for when the analysis seperates conditions. meanwhile getTrialTrigger
        % will return '1'
        curr_trial_trigger = getTrialTrigger(curr_trial_behavioral_data);
        % TODO: relevant for when the analysis seperates conditions. meanwhile
        % cond_i (condition index) will always be 1
        cond_i = find(cellfun(@(cond) strcmp(curr_trial_trigger, cond), CONDS));
        segmentized_eye_data = [];
        search_phase = 1;
        while ~isempty(eye_tracking_data_mat.messages(msg_i).message)
            if search_phase == 1 && strcmp(eye_tracking_data_mat.messages(msg_i).message, curr_trial_trigger)
                trial_start_time_i = find(eye_tracking_data_mat.gazeRight.time == eye_tracking_data_mat.messages(msg_i).time);
                search_phase = 2;
                continue;
            elseif search_phase == 2 && (any(cellfun(@(s) strcmp(eye_tracking_data_mat.messages(msg_i + 1).message, s), CONDS)) || ...
                    strcmp(eye_tracking_data_mat.messages(msg_i + 1).message, END_TRIAL_TRIGGER))
%             elseif search_phase == 2 && any(cellfun(@(s) strcmp(eye_tracking_data_mat.messages(msg_i + 1).message, s), CONDS))               
                trial_end_time_i = find(eye_tracking_data_mat.gazeRight.time == (eye_tracking_data_mat.messages(msg_i + 1).time));
                if isempty(trial_start_time_i) || isempty(trial_end_time_i)
                    segmentized_eye_data.gazeRight = [];
                    segmentized_eye_data.gazeLeft = [];
                else
                    trial_gaze_data_is = trial_start_time_i:trial_end_time_i;
                    segmentized_eye_data.gazeRight = [eye_tracking_data_mat.gazeRight.x(trial_gaze_data_is);
                        eye_tracking_data_mat.gazeRight.y(trial_gaze_data_is)]';
                    segmentized_eye_data.gazeRight(segmentized_eye_data.gazeRight == INVALID_EYE_COORD) = NaN;
                    segmentized_eye_data.gazeLeft = [eye_tracking_data_mat.gazeLeft.x(trial_gaze_data_is);
                        eye_tracking_data_mat.gazeLeft.y(trial_gaze_data_is)]';
                    segmentized_eye_data.gazeLeft(segmentized_eye_data.gazeRight == INVALID_EYE_COORD) = NaN;
                    %segmentized_eye_data.go_trigger_time = go_trigger_time_i - trial_start_time_i + 1;
                end
                msg_i = msg_i + 1;
                search_phase = 1;
                break;
            elseif strcmp(eye_tracking_data_mat.messages(msg_i + 1).message, '200') || ...
                    strcmp(eye_tracking_data_mat.messages(msg_i + 1).message, '201') || ...
                    strcmp(eye_tracking_data_mat.messages(msg_i + 1).message, '68')
                search_phase = 1;
            end
            
            msg_i = msg_i + 1;
        end
        
        % relevant for subject 102/202
        if search_phase == 2
            trial_end_time_i = find(eye_tracking_data_mat.gazeRight.time == (eye_tracking_data_mat.messages(msg_i - 1).time));
            if isempty(trial_start_time_i) || isempty(trial_end_time_i)
                segmentized_eye_data.gazeRight = [];
                segmentized_eye_data.gazeLeft = [];
            else
                trial_gaze_data_is = trial_start_time_i:trial_end_time_i;
                segmentized_eye_data.gazeRight = [eye_tracking_data_mat.gazeRight.x(trial_gaze_data_is);
                    eye_tracking_data_mat.gazeRight.y(trial_gaze_data_is)]';
                segmentized_eye_data.gazeRight(segmentized_eye_data.gazeRight == INVALID_EYE_COORD) = NaN;
                segmentized_eye_data.gazeLeft = [eye_tracking_data_mat.gazeLeft.x(trial_gaze_data_is);
                    eye_tracking_data_mat.gazeLeft.y(trial_gaze_data_is)]';
                segmentized_eye_data.gazeLeft(segmentized_eye_data.gazeRight == INVALID_EYE_COORD) = NaN;
            end
        end
        
        % -----------------------------
        % -----drawing next trial------
        % -----------------------------
        curr_trial_fixations_analysis_struct = analysis_structs_cell_arr{subject_i}.(['c',curr_trial_trigger]).fixations(analysis_struct_iterators(cond_i));
        analysis_struct_iterators(cond_i) = analysis_struct_iterators(cond_i) + 1;
        
        % extracting trial's parameters <<FROM EXPDATA>>
        drawn_pursuit_dur = expdata.info.experiment_parameters.travel_durations(abs(expdata.info.experiment_parameters.travel_durations - curr_trial_behavioral_data.pursuit_duration) < 0.005);
        %drawn_pursuit_dur =10
        ppd = expdata.info.lab_setup.pixels_per_vdegree;
        if curr_trial_behavioral_data.is_gabor_shown            
            if strcmp(curr_trial_behavioral_data.initial_target_side, 'left')
                target_initial_x = expdata.info.experiment_parameters.target_initial_distance_from_edge * ppd;
                target_final_x = target_initial_x + expdata.info.experiment_parameters.target_speed*expdata.info.lab_setup.pixels_per_vdegree*drawn_pursuit_dur;

                if strcmp(curr_trial_behavioral_data.retinotopic_placeholder_side, 'up')
                   
                    upper_placeholder_x = target_final_x + curr_trial_behavioral_data.target_to_retino_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * cos(deg2rad(curr_trial_behavioral_data.target_to_retino_vec_angle));
                    upper_placeholder_y = expdata.info.lab_setup.screen_height_in_pixels / 2 - curr_trial_behavioral_data.target_to_retino_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * sin(deg2rad(curr_trial_behavioral_data.target_to_retino_vec_angle));
                    lower_placeholder_x = target_final_x + curr_trial_behavioral_data.target_to_spatio_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * cos(deg2rad(curr_trial_behavioral_data.target_to_spatio_vec_angle));
                    lower_placeholder_y = expdata.info.lab_setup.screen_height_in_pixels / 2 + curr_trial_behavioral_data.target_to_spatio_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * sin(deg2rad(curr_trial_behavioral_data.target_to_spatio_vec_angle));
                    upper_placeholder_color = expdata.info.experiment_parameters.retinotopic_placeholder_color;
                    lower_placeholder_color = expdata.info.experiment_parameters.spaciotopic_placeholder_color;
                else 
                    upper_placeholder_x = target_final_x + curr_trial_behavioral_data.target_to_spatio_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * cos(deg2rad(curr_trial_behavioral_data.target_to_spatio_vec_angle));
                    upper_placeholder_y = expdata.info.lab_setup.screen_height_in_pixels / 2 - curr_trial_behavioral_data.target_to_spatio_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * sin(deg2rad(curr_trial_behavioral_data.target_to_spatio_vec_angle));
                    lower_placeholder_x = target_final_x + curr_trial_behavioral_data.target_to_retino_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * cos(deg2rad(curr_trial_behavioral_data.target_to_retino_vec_angle));
                    lower_placeholder_y = expdata.info.lab_setup.screen_height_in_pixels / 2 + curr_trial_behavioral_data.target_to_retino_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * sin(deg2rad(curr_trial_behavioral_data.target_to_retino_vec_angle));
                    upper_placeholder_color = expdata.info.experiment_parameters.spaciotopic_placeholder_color;
                    lower_placeholder_color = expdata.info.experiment_parameters.retinotopic_placeholder_color;
                end
                
            elseif strcmp(curr_trial_behavioral_data.initial_target_side, 'right')
                target_initial_x = expdata.info.lab_setup.screen_width_in_pixels - expdata.info.experiment_parameters.target_initial_distance_from_edge * expdata.info.lab_setup.pixels_per_vdegree;
                target_final_x = target_initial_x - expdata.info.experiment_parameters.target_speed*expdata.info.lab_setup.pixels_per_vdegree*drawn_pursuit_dur;
                if strcmp(curr_trial_behavioral_data.retinotopic_placeholder_side, 'up')
                    upper_placeholder_x = target_final_x - curr_trial_behavioral_data.target_to_retino_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * cos(deg2rad(curr_trial_behavioral_data.target_to_retino_vec_angle));
                    upper_placeholder_y = expdata.info.lab_setup.screen_height_in_pixels / 2 - curr_trial_behavioral_data.target_to_retino_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * sin(deg2rad(curr_trial_behavioral_data.target_to_retino_vec_angle));
                    lower_placeholder_x = target_final_x - curr_trial_behavioral_data.target_to_spatio_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * cos(deg2rad(curr_trial_behavioral_data.target_to_spatio_vec_angle));
                    lower_placeholder_y = expdata.info.lab_setup.screen_height_in_pixels / 2 + curr_trial_behavioral_data.target_to_spatio_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * sin(deg2rad(curr_trial_behavioral_data.target_to_spatio_vec_angle));
                    upper_placeholder_color = expdata.info.experiment_parameters.retinotopic_placeholder_color;
                    lower_placeholder_color = expdata.info.experiment_parameters.spaciotopic_placeholder_color;
                else
                    upper_placeholder_x = target_final_x - curr_trial_behavioral_data.target_to_spatio_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * cos(deg2rad(curr_trial_behavioral_data.target_to_spatio_vec_angle));
                    upper_placeholder_y = expdata.info.lab_setup.screen_height_in_pixels / 2 - curr_trial_behavioral_data.target_to_spatio_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * sin(deg2rad(curr_trial_behavioral_data.target_to_spatio_vec_angle));
                    lower_placeholder_x = target_final_x - curr_trial_behavioral_data.target_to_retino_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * cos(deg2rad(curr_trial_behavioral_data.target_to_retino_vec_angle));
                    lower_placeholder_y = expdata.info.lab_setup.screen_height_in_pixels / 2 + curr_trial_behavioral_data.target_to_retino_vec_radius * expdata.info.lab_setup.pixels_per_vdegree * sin(deg2rad(curr_trial_behavioral_data.target_to_retino_vec_angle));
                    upper_placeholder_color = expdata.info.experiment_parameters.spaciotopic_placeholder_color;
                    lower_placeholder_color = expdata.info.experiment_parameters.retinotopic_placeholder_color;
                end
            end
        end %is gabor shown    
        % do the actual animation
        if DO_ANIMATE
            figure();
            axes();            
            set(gca,'yDir', 'reverse', 'xAxisLocation', 'top');
            set(gca, 'title', text(0,0,['trial #', num2str(trial_i), '; gabor appearance side: ', curr_trial_behavioral_data.gabor_appearance_side, '; block type: ', expdata.blocks(curr_trial_behavioral_data.block_number).block_type, '; retinotopic placeholder side: ', curr_trial_behavioral_data.retinotopic_placeholder_side]));
            hold on;
            % draw target at it's initial position
            plot(target_initial_x, expdata.info.lab_setup.screen_height_in_pixels / 2, 'ok', 'markersize', 20);
            % draw the upper placeholder at it's final position
            plot(upper_placeholder_x, upper_placeholder_y, 'o', 'markersize', 60, 'color', upper_placeholder_color);
            % draw the lower placeholder at it's final position
            plot(lower_placeholder_x, lower_placeholder_y, 'o', 'markersize', 60, 'color', lower_placeholder_color);
            
            % calculate the target's travel distance per frame
            if strcmp(curr_trial_behavioral_data.initial_target_side, 'left')
                target_travel_dist_in_millis_per_draw = expdata.info.experiment_parameters.target_speed * expdata.info.lab_setup.pixels_per_vdegree / 1000 * MILLIS_PER_DRAW;
            else
                target_travel_dist_in_millis_per_draw = -expdata.info.experiment_parameters.target_speed * expdata.info.lab_setup.pixels_per_vdegree / 1000 * MILLIS_PER_DRAW;
            end
            time_until_pursuit_onset = (curr_trial_behavioral_data.wait_for_fixation_duration + ...
                curr_trial_behavioral_data.initial_fixation_on_target_duration + ...
                curr_trial_behavioral_data.cue_duration + ...
                curr_trial_behavioral_data.interval_duration_between_cue_and_pursuit)*1000;
            prev_target_x = target_initial_x;
            for sample_i = 1:MILLIS_PER_DRAW:length(segmentized_eye_data.gazeLeft)
                if sample_i > time_until_pursuit_onset
                    % got here if animation got to the pursuit part
                    % erasing the previous frames' target circle ('ow' = white circle)
                    plot(prev_target_x, expdata.info.lab_setup.screen_height_in_pixels / 2, 'ow', 'markersize', 20);
                    % drawing the current  frames' target circle
                    plot(prev_target_x + target_travel_dist_in_millis_per_draw, expdata.info.lab_setup.screen_height_in_pixels / 2, 'ok', 'markersize', 20);
                    prev_target_x = prev_target_x + target_travel_dist_in_millis_per_draw;
                end
                
                % draw subject's eye positions
                if ~isnan(segmentized_eye_data.gazeLeft(sample_i,1))
                    plot(segmentized_eye_data.gazeLeft(sample_i,1), segmentized_eye_data.gazeLeft(sample_i,2), '.g', 'markersize', 5);
                end
                if ~isnan(segmentized_eye_data.gazeRight(sample_i,1))
                    plot(segmentized_eye_data.gazeRight(sample_i,1), segmentized_eye_data.gazeRight(sample_i,2), '.m', 'markersize', 5);
                end
                pause(MILLIS_PER_DRAW/1000);
            end
%             plot(segmentized_eye_data.gazeLeft(:,1), segmentized_eye_data.gazeLeft(:,2), '.g', 'markersize', 5);
%             plot(segmentized_eye_data.gazeRight(:,1), segmentized_eye_data.gazeRight(:,2), '.m', 'markersize', 5);
            % drawing the fixations extracted by kartzidekel
            for fixation_i = 1:numel(curr_trial_fixations_analysis_struct.fixations_onsets)
                if abs(curr_trial_fixations_analysis_struct.fixations_coordinates_left(fixation_i,1) - INVALID_EYE_COORD) > 1e-5 && ...
                        abs(curr_trial_fixations_analysis_struct.fixations_coordinates_right(fixation_i,1) - INVALID_EYE_COORD) > 1e-5
                    % if fixation's both eyes coordinates are valid
                    mean_fixation_coords = mean([curr_trial_fixations_analysis_struct.fixations_coordinates_left(fixation_i,:);
                        curr_trial_fixations_analysis_struct.fixations_coordinates_right(fixation_i,:)]);
                    plot(gca, curr_trial_fixations_analysis_struct.fixations_coordinates_left(fixation_i,1), curr_trial_fixations_analysis_struct.fixations_coordinates_left(fixation_i,2), 'og' , 'markersize', 5);
                    plot(gca, curr_trial_fixations_analysis_struct.fixations_coordinates_right(fixation_i,1), curr_trial_fixations_analysis_struct.fixations_coordinates_right(fixation_i,2), 'om' , 'markersize', 5);
                elseif abs(curr_trial_fixations_analysis_struct.fixations_coordinates_left(fixation_i,1) - INVALID_EYE_COORD) > 1e-5
                    % if fixation's left eye coordinates are valid
                    mean_fixation_coords = curr_trial_fixations_analysis_struct.fixations_coordinates_left(fixation_i,:);
                    plot(gca, curr_trial_fixations_analysis_struct.fixations_coordinates_left(fixation_i,1), curr_trial_fixations_analysis_struct.fixations_coordinates_left(fixation_i,2), 'og' , 'markersize', 5);
                elseif abs(curr_trial_fixations_analysis_struct.fixations_coordinates_right(fixation_i,1) - INVALID_EYE_COORD) > 1e-5
                    % if fixation's right eye coordinates are valid
                    mean_fixation_coords = curr_trial_fixations_analysis_struct.fixations_coordinates_right(fixation_i,:);
                    plot(gca, curr_trial_fixations_analysis_struct.fixations_coordinates_right(fixation_i,1), curr_trial_fixations_analysis_struct.fixations_coordinates_right(fixation_i,2), 'om' , 'markersize', 5);
                else
                    continue;
                end
                text(mean_fixation_coords(1)+4, mean_fixation_coords(2), num2str(fixation_i), 'color', [0 0 0]);
                text(mean_fixation_coords(1)-15, mean_fixation_coords(2), num2str(curr_trial_fixations_analysis_struct.fixations_durations(fixation_i)), 'color', [0 0 0]);
            end
        end
        
        %         start_fixation_index_according_to_online = identifyOfflineFixationByOnlineCoords(offline_fixations, expdata.trials(trial_i).fixation_dot_position, curr_trial_fixations_analysis_struct.fixations_durations, @(v) find(v == max(v), 1));
        %         assert(~isempty(start_fixation_index_according_to_online));
        %         analysis_struct.analysis(trial_i).start_fixation_index_according_to_online = start_fixation_index_according_to_online;
        %         if isnan(online_response_fixation)
        %             if numel(analysis_struct.saccades(trial_i).onsets) >= start_fixation_index_according_to_online
        %                 analysis_struct.analysis(trial_i).response_saccade_onset = ...
        %                     analysis_struct.saccades(trial_i).onsets(start_fixation_index_according_to_online) - segmentized_eye_data(trial_i).go_trigger_time;
        %             else
        %                 analysis_struct.analysis(trial_i).response_saccade_onset = [];
        %             end
        %             analysis_struct.analysis(trial_i).first_to_response_fixation_vector_direction = ...
        %                 rad2deg(atan2(offline_fixations(start_fixation_index_according_to_online, 2) - offline_fixations(end, 2), offline_fixations(end, 1) - offline_fixations(start_fixation_index_according_to_online, 1)));
        %             analysis_struct.analysis(trial_i).first_to_response_fixation_vector_amplitude = ...
        %                 sqrt(sum((offline_fixations(start_fixation_index_according_to_online, :) - offline_fixations(end, :)).^2)) / expdata.info.lab_setup.pixels_per_vdegree;
        %             for fix_i = 1:fixations_nr
        %                 analysis_struct.analysis(trial_i).distance_between_offline_response_fixation_and_target = ...
        %                 	sqrt(sum((offline_fixations(fix_i,:) - expdata.trials(trial_i).saccade_target_location).^2)) / expdata.info.lab_setup.pixels_per_vdegree;
        %             end
        %             response_fixation_index_according_to_online = [];
        %         elseif fixations_nr >= 2
        %             response_fixation_index_according_to_online = identifyOfflineFixationByOnlineCoords(offline_fixations, online_response_fixation, curr_trial_fixations_analysis_struct.fixations_onsets, @(v) find(v == max(v), 1));
        %             if ~isempty(response_fixation_index_according_to_online)
        %                 if numel(analysis_struct.saccades(trial_i).onsets) >= start_fixation_index_according_to_online
        %                     analysis_struct.analysis(trial_i).response_saccade_onset = ...
        %                         analysis_struct.saccades(trial_i).onsets(start_fixation_index_according_to_online) - segmentized_eye_data(trial_i).go_trigger_time;
        %                 else
        %                     analysis_struct.analysis(trial_i).response_saccade_onset = [];
        %                 end
        %                 analysis_struct.analysis(trial_i).first_to_response_fixation_vector_direction = ...
        %                     rad2deg(atan2(offline_fixations(start_fixation_index_according_to_online, 2) - offline_fixations(response_fixation_index_according_to_online, 2), offline_fixations(response_fixation_index_according_to_online, 1) - offline_fixations(start_fixation_index_according_to_online, 1)));
        %                 analysis_struct.analysis(trial_i).first_to_response_fixation_vector_amplitude = ...
        %                     sqrt(sum((offline_fixations(start_fixation_index_according_to_online, :) - offline_fixations(response_fixation_index_according_to_online, :)).^2)) / expdata.info.lab_setup.pixels_per_vdegree;
        %
        %                 analysis_struct.analysis(trial_i).distance_between_offline_response_fixation_and_target = ...
        %                     sqrt(sum((offline_fixations(response_fixation_index_according_to_online,:) - expdata.trials(trial_i).saccade_target_location).^2)) / expdata.info.lab_setup.pixels_per_vdegree;
        %                 analysis_struct.analysis(trial_i).distance_between_online_response_fixation_and_target = ...
        %                     sqrt(sum((online_response_fixation - expdata.trials(trial_i).saccade_target_location).^2)) / expdata.info.lab_setup.pixels_per_vdegree;
        %             else
        %                 analysis_struct.analysis(trial_i).response_saccade_onset = [];
        %                 analysis_struct.analysis(trial_i).first_to_response_fixation_vector_direction = [];
        %                 analysis_struct.analysis(trial_i).first_to_response_fixation_vector_amplitude = [];
        %                 analysis_struct.analysis(trial_i).distance_between_offline_response_fixation_and_target = [];
        %                 analysis_struct.analysis(trial_i).distance_between_online_response_fixation_and_target = [];
        %             end
        %         elseif fixations_nr == 1
        %             response_fixation_index_according_to_online = 1;
        %             analysis_struct.analysis(trial_i).response_saccade_onset = [];
        %             analysis_struct.analysis(trial_i).first_to_response_fixation_vector_direction = [];
        %             analysis_struct.analysis(trial_i).first_to_response_fixation_vector_amplitude = [];
        %             analysis_struct.analysis(trial_i).distance_between_offline_response_fixation_and_target = [];
        %             analysis_struct.analysis(trial_i).distance_between_online_response_fixation_and_target = [];
        %         else
        %             response_fixation_index_according_to_online = [];
        %             analysis_struct.analysis(trial_i).response_saccade_onset = [];
        %             analysis_struct.analysis(trial_i).first_to_response_fixation_vector_direction = [];
        %             analysis_struct.analysis(trial_i).first_to_response_fixation_vector_amplitude = [];
        %             analysis_struct.analysis(trial_i).distance_between_offline_response_fixation_and_target = [];
        %             analysis_struct.analysis(trial_i).distance_between_online_response_fixation_and_target = [];
        %         end
        %         analysis_struct.analysis(trial_i).response_fixation_index_according_to_online = response_fixation_index_according_to_online;
        %         analysis_struct.analysis(trial_i).saccades_number_to_target = ...
        %                 analysis_struct.analysis(trial_i).response_fixation_index_according_to_online - analysis_struct.analysis(trial_i).start_fixation_index_according_to_online;
        %         analysis_struct.analysis(trial_i).online_feedback = expdata.trials(trial_i).response_result;
        %
        %         if DO_ANIMATE
        %             if ~isempty(response_fixation_index_according_to_online)
        %                 if abs(analysis_struct.fixations(trial_i).fixations_coordinates_left(response_fixation_index_according_to_online,1) - INVALID_EYE_COORD) > 1e-5
        %                     plot(gca, analysis_struct.fixations(trial_i).fixations_coordinates_left(response_fixation_index_according_to_online, 1), ...
        %                           analysis_struct.fixations(trial_i).fixations_coordinates_left(response_fixation_index_according_to_online, 2), ...,
        %                           'oc' , 'markersize', 5);
        %                 end
        %                 if abs(analysis_struct.fixations(trial_i).fixations_coordinates_right(response_fixation_index_according_to_online,1) - INVALID_EYE_COORD) > 1e-5
        %                     plot(gca, analysis_struct.fixations(trial_i).fixations_coordinates_right(response_fixation_index_according_to_online, 1), ...
        %                           analysis_struct.fixations(trial_i).fixations_coordinates_right(response_fixation_index_according_to_online, 2), ...,
        %                           'oc' , 'markersize', 5);
        %                 end
        %                 if abs(analysis_struct.fixations(trial_i).fixations_coordinates_left(start_fixation_index_according_to_online,1) - INVALID_EYE_COORD) > 1e-5
        %                     plot(gca, analysis_struct.fixations(trial_i).fixations_coordinates_left(start_fixation_index_according_to_online, 1), ...
        %                           analysis_struct.fixations(trial_i).fixations_coordinates_left(start_fixation_index_according_to_online, 2), ...,
        %                           'om' , 'markersize', 5);
        %                 end
        %                 if abs(analysis_struct.fixations(trial_i).fixations_coordinates_right(start_fixation_index_according_to_online,1) - INVALID_EYE_COORD) > 1e-5
        %                     plot(gca, analysis_struct.fixations(trial_i).fixations_coordinates_right(start_fixation_index_according_to_online, 1), ...
        %                           analysis_struct.fixations(trial_i).fixations_coordinates_right(start_fixation_index_according_to_online, 2), ...,
        %                           'om' , 'markersize', 5);
        %                 end
        %             end
        %         end
        %
        %         if ~isempty(response_fixation_index_according_to_online) && response_fixation_index_according_to_online < fixations_nr
        %             analysis_struct.analysis(trial_i).is_fixation_after_accepted_one_on_target = ...
        %                 sum((analysis_struct.fixations(trial_i).fixations_coordinates_left(response_fixation_index_according_to_online + 1, :) - expdata.trials(trial_i).saccade_target_location).^2) <= expdata.info.lab_setup.pixels_per_vdegree^2 | ...
        %                 sum((analysis_struct.fixations(trial_i).fixations_coordinates_right(response_fixation_index_according_to_online + 1, :) - expdata.trials(trial_i).saccade_target_location).^2) <= expdata.info.lab_setup.pixels_per_vdegree^2;
        %         else
        %             analysis_struct.analysis(trial_i).is_fixation_after_accepted_one_on_target = [];
        %         end
        
        if DO_ANIMATE
            keyboard;
        end
    end
    
    close all
    disp(['done with subject #', num2str(subject_i), '.']);
    analysis_structs_cell_arr{subject_i} = analysis_struct;
end

disp('saving analysis data.');
save(fullfile(DATA_FOLDER, 'analysis_struct_augmented.mat'), 'analysis_structs_cell_arr');
disp('Done.');

%leof = long enough offline fixation
% function online_taken_fixation_index =  identifyOfflineFixationByOnlineCoords(offline_fixations, online_coords, tie_break_data_vec, tie_break_decision_func)
%     leofs_is = find(analysis_struct.fixations(trial_i).fixations_durations > 70);
%     leofs_nr = numel(leofs_is);
%     leofs_dists_from_online_coords = NaN(leofs_nr, 1);
%     for leof_ii = 1:leofs_nr
%         leofs_dists_from_online_coords(leof_ii) = sum((offline_fixations(leofs_is(leof_ii),:) - online_coords).^2);
%     end
%
%     [~, leofs_sort_i] = sort(leofs_dists_from_online_coords);
%     % taking into consideration only the 2 closest fixations to the
%     % online coordinates
%     if numel(leofs_sort_i) >= 2
%         closest_leofs_is = leofs_is(leofs_sort_i(1:2));
%     else
%         closest_leofs_is = leofs_is(leofs_sort_i);
%     end
%
%     if numel(closest_leofs_is) == 2
%         if sqrt(sum((offline_fixations(closest_leofs_is(1),:) - offline_fixations(closest_leofs_is(2),:)).^2)) <= 2*expdata.info.lab_setup.pixels_per_vdegree
%             online_taken_fixation_index = closest_leofs_is(tie_break_decision_func(tie_break_data_vec(closest_leofs_is)));
%         else
%             online_taken_fixation_index = leofs_is(leofs_dists_from_online_coords == min(leofs_dists_from_online_coords));
%         end
%     elseif numel(closest_leofs_is) == 1
%         online_taken_fixation_index = closest_leofs_is;
%     else
%         online_taken_fixation_index = [];
%     end
% end


end


