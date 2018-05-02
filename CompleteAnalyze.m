function result = CompleteAnalyze(subjectNumber, Race, Diffusion)

    BehevioralMatFilePath = fullfile('resources','data files','behavioral data',['expdata',subjectNumber,'.mat']);
    analyesedStractFilePath = fullfile('resources','matlabFiles',['s',subjectNumber],'analysis_struct.mat');
    PolititionsFile = "PolititiansWithFacePositions.mat";
    analyesedStractFilePathWithoutFile = fullfile('resources','matlabFiles');
    try
        load(analyesedStractFilePath);
        load(BehevioralMatFilePath);
        load(PolititionsFile);
        disp('Loading succesfull');
    catch
        disp('Could not open files');
        return;
    end
    %TMP objects
    averagedCandidatesRankTemp = cell(60,1);
    endTrialsIndex = length(analysis_struct{1, 1}.c2.fixations(1,:));
    resultModelsPredicted = zeros(endTrialsIndex,4);
    for i = 1:endTrialsIndex
        %check for ESC press:
        if analysis_struct{1, 1}.c2.fixations(i).fixations_onsets == 1
            continue;
        end
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
        leftPicNum = EXPDATA.trials(i).left_picture;
        rightPicNum = EXPDATA.trials(i).right_picture;
        picLeftRangeX = [200,760];
        picRightRangeX = [1150,1710];
        picsRangeY = [100,940];
        picsRangeEyesY = [250,450];
        picsLeftFaceRangeX = [picLeftRangeX(1)+(Polititians.FaceXStart(leftPicNum)*2),picLeftRangeX(1)+(Polititians.FaceXEnd(leftPicNum)*2)];
        picsLeftFaceRangeY = [picsRangeY(1)+(Polititians.FaceYStart(leftPicNum)*2),picsRangeY(1)+(Polititians.FaceYEnd(leftPicNum)*2)];
        picsRightFaceRangeX = [picRightRangeX(1)+(Polititians.FaceXStart(rightPicNum)*2),picRightRangeX(1)+(Polititians.FaceXEnd(rightPicNum)*2)];
        picsRightFaceRangeY = [picsRangeY(1)+(Polititians.FaceYStart(rightPicNum)*2),picsRangeY(1)+(Polititians.FaceYEnd(rightPicNum)*2)];
        lookLeftDurations = zeros([],2);
        lookRightDurations = zeros([],2);
        indexLeft = 1;
        indexRight = 1;
        lookLeftEyesDurations = zeros([],2);
        lookRightEyesDurations = zeros([],2);
        indexEyesLeft = 1;
        indexEyesRight = 1;
        lookLeftFaceDurations = zeros([],2);
        lookRightFaceDurations = zeros([],2);
        indexFaceLeft = 1;
        indexFaceRight = 1;
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
            if ((myAvarage(intI,1) >= picLeftRangeX(1)) && (myAvarage(intI,1) <= picLeftRangeX(2)) && ...
                    (myAvarage(intI,2) >= picsRangeEyesY(1)) && (myAvarage(intI,2) <= picsRangeEyesY(2)))
                lookLeftEyesDurations(indexEyesLeft,1) = analysis_struct{1, 1}.c2.fixations(i).fixations_onsets(intI);
                lookLeftEyesDurations(indexEyesLeft,2) = analysis_struct{1, 1}.c2.fixations(i).fixations_durations(intI);
                indexEyesLeft = indexEyesLeft + 1;
            elseif ((myAvarage(intI,1) >= picRightRangeX(1)) && (myAvarage(intI,1) <= picRightRangeX(2)) && ...
                    (myAvarage(intI,2) >= picsRangeEyesY(1)) && (myAvarage(intI,2) <= picsRangeEyesY(2)))
                lookRightEyesDurations(indexEyesRight,1) = analysis_struct{1, 1}.c2.fixations(i).fixations_onsets(intI);
                lookRightEyesDurations(indexEyesRight,2) = analysis_struct{1, 1}.c2.fixations(i).fixations_durations(intI);
                indexEyesRight = indexEyesRight + 1;
            end
            if ((myAvarage(intI,1) >= picsLeftFaceRangeX(1)) && (myAvarage(intI,1) <= picsLeftFaceRangeX(2)) && ...
                (myAvarage(intI,2) >= picsLeftFaceRangeY(1)) && (myAvarage(intI,2) <= picsLeftFaceRangeY(2)))
                lookLeftFaceDurations(indexFaceLeft,1) = analysis_struct{1, 1}.c2.fixations(i).fixations_onsets(intI);
                lookLeftFaceDurations(indexFaceLeft,2) = analysis_struct{1, 1}.c2.fixations(i).fixations_durations(intI);
                indexFaceLeft = indexFaceLeft + 1;
            elseif ((myAvarage(intI,1) >= picsRightFaceRangeX(1)) && (myAvarage(intI,1) <= picsRightFaceRangeX(2)) && ...
                (myAvarage(intI,2) >= picsRightFaceRangeY(1)) && (myAvarage(intI,2) <= picsRightFaceRangeY(2)))
                lookRightFaceDurations(indexFaceRight,1) = analysis_struct{1, 1}.c2.fixations(i).fixations_onsets(intI);
                lookRightFaceDurations(indexFaceRight,2) = analysis_struct{1, 1}.c2.fixations(i).fixations_durations(intI);
                indexFaceRight = indexFaceRight + 1;
            end
        end
        %pic%
        analysis_struct{1, 1}.c2.fixations(i).left_pic_duration_per_fixastion = lookLeftDurations;
        analysis_struct{1, 1}.c2.fixations(i).left_pic_duration_sum = sum(lookLeftDurations(:,2));
        analysis_struct{1, 1}.c2.fixations(i).right_pic_duration_per_fixastion = lookRightDurations;
        analysis_struct{1, 1}.c2.fixations(i).right_pic_duration_sum = sum(lookRightDurations(:,2));
        %eyes%
        analysis_struct{1, 1}.c2.fixations(i).eyes_of_left_pic_duration_per_fixastion = lookLeftEyesDurations;
        analysis_struct{1, 1}.c2.fixations(i).eyes_of_left_pic_duration_sum = sum(lookLeftEyesDurations(:,2));
        analysis_struct{1, 1}.c2.fixations(i).eyes_of_right_pic_duration_per_fixastion = lookRightEyesDurations;
        analysis_struct{1, 1}.c2.fixations(i).eyes_of_right_pic_duration_sum = sum(lookRightEyesDurations(:,2));
        %face%
        analysis_struct{1, 1}.c2.fixations(i).face_of_left_pic_duration_per_fixastion = lookLeftFaceDurations;
        analysis_struct{1, 1}.c2.fixations(i).face_of_left_pic_duration_sum = sum(lookLeftFaceDurations(:,2));
        analysis_struct{1, 1}.c2.fixations(i).face_of_right_pic_duration_per_fixastion = lookRightFaceDurations;
        analysis_struct{1, 1}.c2.fixations(i).face_of_right_pic_duration_sum = sum(lookRightFaceDurations(:,2));
        
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
        passesToLeft = 0;
        passesToRight = 0;
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
                if passes_tmp(passesI-1) < passes_tmp(passesI)
                    passesToLeft = passesToLeft +1;
                elseif passes_tmp(passesI-1) > passes_tmp(passesI)
                    passesToRight = passesToRight +1;
                end
            end
        end
        analysis_struct{1, 1}.c2.fixations(i).passes_to_left = passesToLeft;
        analysis_struct{1, 1}.c2.fixations(i).passes_to_right = passesToRight;
        
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
        %Put in a list all the candidate ranks
        picLeftNum = EXPDATA.trials(i).left_picture;
        picRightNum = EXPDATA.trials(i).right_picture;
        if (~(isnan(picLeftNum) || isnan(analysis_struct{1, 1}.c2.fixations(i).left_picture_rank)))
                averagedCandidatesRankTemp{picLeftNum}(length(averagedCandidatesRankTemp{picLeftNum})+1) = EXPDATA.trials(i).left_picture_rank;
        end
        if (~(isnan(picRightNum) || isnan(analysis_struct{1, 1}.c2.fixations(i).right_picture_rank)))
                 averagedCandidatesRankTemp{picRightNum}(length(averagedCandidatesRankTemp{picRightNum})+1) = EXPDATA.trials(i).right_picture_rank;
        end   
        
        %checking the models on the data
        if EXPDATA.trials(i).response == 0 || EXPDATA.trials(i).response == 1
            modelsPredicted = data2models(lookLeftFaceDurations, lookRightFaceDurations,Race, Diffusion);
        else
            modelsPredicted = [0,0,0,0];
        end
        if (modelsPredicted(1) == 0 && EXPDATA.trials(i).response == 0) ...
                || (modelsPredicted(1) == 1 && EXPDATA.trials(i).response == 1)
            resultModelsPredicted(i,[1,2]) = [1,modelsPredicted(2)];
            analysis_struct{1, 1}.c2.fixations(i).race_model_predicted_response = 'YES';
        elseif (modelsPredicted(1) ~= 0 && EXPDATA.trials(i).response == 0) ...
                || (modelsPredicted(1) ~= 1 && EXPDATA.trials(i).response == 1)
            resultModelsPredicted(i,[1,2]) = [0,modelsPredicted(2)];            
            analysis_struct{1, 1}.c2.fixations(i).race_model_predicted_response = 'NO';
        else
            resultModelsPredicted(i,[1,2]) = [NaN,0];
            analysis_struct{1, 1}.c2.fixations(i).race_model_predicted_response = 'NULL';
        end
        if (modelsPredicted(3) == 0 && EXPDATA.trials(i).response == 0) ...
                || (modelsPredicted(3) == 1 && EXPDATA.trials(i).response == 1)
            resultModelsPredicted(i,[3,4]) = [1,modelsPredicted(4)];
            analysis_struct{1, 1}.c2.fixations(i).diffusion_model_predicted_response = 'YES';
        elseif (modelsPredicted(3) ~= 0 && EXPDATA.trials(i).response == 0) ...
                || (modelsPredicted(3) ~= 1 && EXPDATA.trials(i).response == 1)
            resultModelsPredicted(i,[3,4]) = [0,modelsPredicted(4)];            
            analysis_struct{1, 1}.c2.fixations(i).diffusion_model_predicted_response = 'NO';            
        else
            resultModelsPredicted(i,[3,4]) = [NaN,0];
            analysis_struct{1, 1}.c2.fixations(i).diffusion_model_predicted_response = 'NULL';
        end 
        %save the struct%
        save(analyesedStractFilePath,'analysis_struct');
    end
    averagedCandidatesRank = cellfun(@mean,averagedCandidatesRankTemp);
    PresentageOfConsistency = WhatIsThePresentageOfConsistency(averagedCandidatesRank, endTrialsIndex,EXPDATA.trials);
    resultRacePredicted = length(find(resultModelsPredicted(:,1)==1))/length(find(~isnan(resultModelsPredicted(:,1))));
    resultDiffusionPredicted = length(find(resultModelsPredicted(:,3)==1))/length(find(~isnan(resultModelsPredicted(:,3))));
    if resultRacePredicted < 0.48 && resultDiffusionPredicted < 0.48
        modelsPredictedOtherDirectionTrue = subjectLookingAt(averagedCandidatesRank, analysis_struct{1, 1}.c2.fixations, endTrialsIndex);
    else
        modelsPredictedOtherDirectionTrue = NaN;
    end
    result = {subjectNumber, PresentageOfConsistency, resultRacePredicted, resultDiffusionPredicted, modelsPredictedOtherDirectionTrue};
    disp("-------Complete Subject "+subjectNumber+"--------");
end