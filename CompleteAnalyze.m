function CompleteAnalyze()
    prompt = 'Please enter the number of subject (in order to get the behevioral struct): ';
    subjectNumber = input(prompt,'s');
    BehevioralMatFilePath = fullfile('resources','data files','behavioral data',['expdata',subjectNumber,'.mat']);
    analyesedStractFilePath = fullfile('resources','matlabFiles','analysis_struct.mat');
    analyesedStractFilePathWithoutFile = fullfile('resources','matlabFiles');
    try
        load(analyesedStractFilePath);
        load(BehevioralMatFilePath);
        disp('loading succesfull');
    catch
        disp('could not open file');
    end
    for i = 1:100
        %response%
        if EXPDATA.trials(i).response == 0
            analysis_struct{1, 1}.c2.fixations(i).response = 'Left';
            analysis_struct{1, 1}.c2.saccades(i).response = 'Left';
        elseif EXPDATA.trials(i).response == 1
            analysis_struct{1, 1}.c2.fixations(i).response = 'Right';
            analysis_struct{1, 1}.c2.saccades(i).response = 'Right';
        elseif EXPDATA.trials(i).response == 2
            analysis_struct{1, 1}.c2.fixations(i).response = 'Down - abstain';
            analysis_struct{1, 1}.c2.saccades(i).response = 'Down - abstain';
        else
            analysis_struct{1, 1}.c2.fixations(i).response = NaN;
            analysis_struct{1, 1}.c2.saccades(i).response = NaN;
        end
    
        %left picture rank%
        analysis_struct{1, 1}.c2.fixations(i).left_picture_rank = EXPDATA.trials(i).left_picture_rank;
        analysis_struct{1, 1}.c2.saccades(i).left_picture_rank = EXPDATA.trials(i).left_picture_rank;
        analysis_struct{1, 1}.c2.fixations(i).right_picture_rank = EXPDATA.trials(i).right_picture_rank;
        analysis_struct{1, 1}.c2.saccades(i).right_picture_rank = EXPDATA.trials(i).right_picture_rank;
    
        %left picture politician%
        analysis_struct{1, 1}.c2.fixations(i).left_picture = EXPDATA.trials(i).left_picture;
        analysis_struct{1, 1}.c2.saccades(i).left_picture = EXPDATA.trials(i).left_picture;
        analysis_struct{1, 1}.c2.fixations(i).left_picture_politician = picToPolitician(EXPDATA.trials(i).left_picture);
        analysis_struct{1, 1}.c2.saccades(i).left_picture_politician = picToPolitician(EXPDATA.trials(i).left_picture);
        %right picture politician%
        analysis_struct{1, 1}.c2.fixations(i).right_picture = EXPDATA.trials(i).right_picture;
        analysis_struct{1, 1}.c2.saccades(i).right_picture = EXPDATA.trials(i).right_picture;
        analysis_struct{1, 1}.c2.fixations(i).right_picture_politician = picToPolitician(EXPDATA.trials(i).right_picture);
        analysis_struct{1, 1}.c2.saccades(i).right_picture_politician = picToPolitician(EXPDATA.trials(i).right_picture);
        
        %avarage of X and Y coardinations from both eyes%
        myAvarage = zeros(length(analysis_struct{1, 1}.c2.fixations(i).fixations_coordinates_left),2);
        for j = 1:length(myAvarage(:,1))
            if ((analysis_struct{1, 1}.c2.fixations(i).fixations_coordinates_left(j,1) == -2^15) | (analysis_struct{1, 1}.c2.fixations(i).fixations_coordinates_left(j,2) == -2^15)...
                | (analysis_struct{1, 1}.c2.fixations(i).fixations_coordinates_right(j,1) == -2^15) | (analysis_struct{1, 1}.c2.fixations(i).fixations_coordinates_right(j,2) == -2^15))
                myAvarage(j,1) = NaN;
                myAvarage(j,2) = NaN;
            else
            myAvarage(j,1) = ((analysis_struct{1, 1}.c2.fixations(i).fixations_coordinates_left(j,1))+(analysis_struct{1, 1}.c2.fixations(i).fixations_coordinates_right(j,1)))/2;
            myAvarage(j,2) = ((analysis_struct{1, 1}.c2.fixations(i).fixations_coordinates_left(j,2))+(analysis_struct{1, 1}.c2.fixations(i).fixations_coordinates_right(j,2)))/2;
            end
        end
        analysis_struct{1, 1}.c2.fixations(i).avarage_coardinations = myAvarage;
        
        %microsacadas%
        size = length(analysis_struct{1, 1}.c2.saccades(1).amplitudes);
        myMicrosacadas = [];
        microI = 1;
        for s = 1:size
            if analysis_struct{1, 1}.c2.saccades(1).amplitudes(s) < 1
                myMicrosacadas(microI) = analysis_struct{1, 1}.c2.saccades(1).amplitudes(s);
                microI = microI + 1;
            end
        end
        analysis_struct{1, 1}.c2.saccades(i).microsacadas = myMicrosacadas;
        
        %time that the subject looked on each pic%
        picLeftRangeX = [200,760];
        picRightRangeX = [1150,1710];
        picsRangeY = [100,940];
        lookLeftDurations = zeros([],2);
        lookRightDurations = zeros([],2);
        indexLeft = 1;
        indexRight = 1;
        for intI = 1:length(myAvarage(:,1))
            %checking left picture fixation
            if ((myAvarage(intI,1) >= picLeftRangeX(1)) && (myAvarage(intI,1) <= picLeftRangeX(2)) && ...
                    (myAvarage(intI,2) >= picsRangeY(1)) && (myAvarage(intI,2) <= picsRangeY(2)))
                lookLeftDurations(indexLeft,1) = analysis_struct{1, 1}.c2.fixations(i).fixations_onsets(intI);
                lookLeftDurations(indexLeft,2) = analysis_struct{1, 1}.c2.fixations(i).fixations_durations(intI);
                indexLeft = indexLeft + 1;
            elseif ((myAvarage(intI,1) >= picRightRangeX(1)) && (myAvarage(intI,1) <= picRightRangeX(2)) && ...
                    (myAvarage(intI,2) >= picsRangeY(1)) && (myAvarage(intI,2) <= picsRangeY(2)))
                lookRightDurations(indexRight,1) = analysis_struct{1, 1}.c2.fixations(i).fixations_onsets(intI);
                lookRightDurations(indexRight,2) = analysis_struct{1, 1}.c2.fixations(i).fixations_durations(intI);
                indexRight = indexRight + 1;
            end
        end
        
        analysis_struct{1, 1}.c2.fixations(i).left_pic_duration_per_fixastion = lookLeftDurations;
        analysis_struct{1, 1}.c2.fixations(i).left_pic_duration_sum = sum(lookLeftDurations(:,2));
        analysis_struct{1, 1}.c2.fixations(i).right_pic_duration_per_fixastion = lookRightDurations;
        analysis_struct{1, 1}.c2.fixations(i).right_pic_duration_sum = sum(lookRightDurations(:,2));
        
        %duration predicted response%
        if i > 50
            analysis_struct{1, 1}.c2.fixations(i).duration_predicted_response = NaN;
        elseif ((sum(lookRightDurations(:,2)) > sum(lookLeftDurations(:,2))) && strcmp('Left',analysis_struct{1, 1}.c2.fixations(i).response))...
             | ((sum(lookRightDurations(:,2)) < sum(lookLeftDurations(:,2))) && strcmp('Right',analysis_struct{1, 1}.c2.fixations(i).response))
            analysis_struct{1, 1}.c2.fixations(i).duration_predicted_response = 'Yes';
        else
            analysis_struct{1, 1}.c2.fixations(i).duration_predicted_response = 'No';

        end
        
        %passes from one picture to another%
        passes = 0;
        size = length(lookLeftDurations(:,1)) + length(lookRightDurations(:,1));
        passes_tmp = zeros(size,1);
        index_left = 1;
        index_leftMax = length(lookLeftDurations(:,1));
        index_rightMax = length(lookRightDurations(:,1));
        index_right = 1;
        passesIndex = 1;
        if index_leftMax > 0 && index_rightMax > 0
            while (index_left <= index_leftMax && index_right <= index_rightMax)
                if lookLeftDurations(index_left,1) < lookRightDurations(index_right,1)
                    passes_tmp(passesIndex) = 0;
                    index_left = index_left + 1 ;
                else
                    passes_tmp(passesIndex) = 1;
                    index_right = index_right + 1 ;
                end
                passesIndex = passesIndex + 1;
            end
        end
        if index_left < index_leftMax
            for tmpInd = index_left : index_leftMax
                passes_tmp(passesIndex) = 0;
                passesIndex = passesIndex + 1;
            end
        elseif index_right < index_rightMax
            for tmpInd = index_right : index_rightMax
                passes_tmp(passesIndex) = 1;
                passesIndex = passesIndex + 1;
            end
        end
            
        if passesIndex > 1
            for passesI = 2:(passesIndex-1)
                if passes_tmp(passesI-1) ~= passes_tmp(passesI)
                    passes = passes +1;
                end
            end
        end
        analysis_struct{1, 1}.c2.fixations(i).total_passes = passes;
        
        %last fixation and prediction%
        if ((passes_tmp(length(passes_tmp)) == 0) && (strcmp('Left',analysis_struct{1, 1}.c2.fixations(i).response)))
            analysis_struct{1, 1}.c2.fixations(i).last_fixation_predicted_response = 'Yes';
        elseif ((passes_tmp(length(passes_tmp)) == 0) && (strcmp('Right',analysis_struct{1, 1}.c2.fixations(i).response)))
            analysis_struct{1, 1}.c2.fixations(i).last_fixation_predicted_response = 'NO';
        elseif ((passes_tmp(length(passes_tmp)) == 1) && (strcmp('Right',analysis_struct{1, 1}.c2.fixations(i).response)))
            analysis_struct{1, 1}.c2.fixations(i).last_fixation_predicted_response = 'Yes';
        elseif ((passes_tmp(length(passes_tmp)) == 1) && (strcmp('Left',analysis_struct{1, 1}.c2.fixations(i).response)))
            analysis_struct{1, 1}.c2.fixations(i).last_fixation_predicted_response = 'NO';
        else
            analysis_struct{1, 1}.c2.fixations(i).last_fixation_predicted_response = 'Abstained';
        end
        %save the struct%
        save(analyesedStractFilePath,'analysis_struct');
    end
    disp('-------Complete!--------');
end