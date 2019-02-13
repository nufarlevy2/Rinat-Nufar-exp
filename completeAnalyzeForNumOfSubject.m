function completeAnalyzeForNumOfSubject(subjectNumbers, parameters, NUM_OF_TRIALS_FOR_MULTIPLE_CHECKS)
%     prompt = 'Please enter the numbers of all subjects seperated with - ",": ';
%     subjectNumbersTemp = input(prompt,'s');
%     subjectNumbers = strsplit(subjectNumbersTemp,",");
%     subjectNumbers = {'100', '105', '107', '108', '110', '113', '115', '116', '117'};
%    subjectNumbers = {'100', '107', '108', '110', '113', '115', '116', '117'};
%     subjectNumbers = {'108', '110'};
    means.primaryInput = 0;
    means.secondaryInput = 0;
    len = length(subjectNumbers);
%    parameters = [[0.95,0.05,0.3]; [1,0,0.3]];
%     parameters = [[0.95,0.05,0.3]];
%    parameters = [[1,0,0.3];[0.95,0.05,0.3];[0.9,0.1,0.3];[0.85,0.15,0.3];[0.8,0.2,0.3];[1,0,0.5];[0.95,0.05,0.5];[0.9,0.1,0.5];[0.85,0.15,0.5];[0.8,0.2,0.5]];
    if len <= 0
        disp('Please give at least one subject number!');
        return;
    end
    switch nargin
        case 1
            parameters = [[0.95,0.05,0.3]];
            NUM_OF_TRIALS_FOR_MULTIPLE_CHECKS = 1;
        case 2
            NUM_OF_TRIALS_FOR_MULTIPLE_CHECKS = 1;
    end
    for trialNum = 1:NUM_OF_TRIALS_FOR_MULTIPLE_CHECKS
        for parameter = 1:length(parameters(:,1)) 
            LCA.Threshold = 10^10;
            LCA.primaryInput = parameters(parameter,1);
            LCA.SecondaryInput = parameters(parameter,2);
            LCA.noiseM = 0;
            LCA.noiseSTD = parameters(parameter,3);
            LCA.Leak = 0.2;
            LCA.Inhibition = 0.2;
            Race.Threshold = 10^10;
            Race.primaryInput = parameters(parameter,1);
            Race.SecondaryInput = parameters(parameter,2);
            Race.noiseM = 0;
            Race.noiseSTD = parameters(parameter,3);
            Diffusion.Threshold = 10^10;
            Diffusion.primaryInput = parameters(parameter,1);
            Diffusion.SecondaryInput = parameters(parameter,2);
            Diffusion.noiseM = 0;
            Diffusion.noiseSTD = parameters(parameter,3);
            means(parameter).primaryInput = Race.primaryInput;
            means(parameter).secondaryInput = Race.SecondaryInput;
            means(parameter).noiseSTD = Race.noiseSTD;
            parfor inti = 1:len
                tmp = CompleteAnalyze(subjectNumbers{inti},Race, Diffusion, LCA);
                finalReport(inti).subjectNumber = str2double(tmp{1});
                finalReport(inti).RankMatchesModelsOtherDirectionPresentage = round(tmp{5},2);
                finalReport(inti).ReliablePrecentage = round(tmp{2},2);
                finalReport(inti).RaceAccuracyOrigin = round(tmp{3},2)*100;
                finalReport(inti).DiffusionAccuracyOrigin = round(tmp{4},2)*100;
                finalReport(inti).LCAAccuracyOrigin = round(tmp{6},2)*100;
                finalReport(inti).RaceAccuracyHalf1Origin = round(tmp{7},2)*100;
                finalReport(inti).RaceAccuracyHalf2Origin = round(tmp{8},2)*100;
                finalReport(inti).DiffusionAccuracyHalf1Origin = round(tmp{9},2)*100;
                finalReport(inti).DiffusionAccuracyHalf2Origin = round(tmp{10},2)*100;
                finalReport(inti).LCAAccuracyHalf1Origin = round(tmp{11},2)*100;
                finalReport(inti).LCAAccuracyHalf2Origin = round(tmp{12},2)*100;
                if mean([round(tmp{3},2), round(tmp{4},2), round(tmp{6},2)]) < 0.48
                    finalReport(inti).RaceAccuracyFinal = (1-round(tmp{3},2))*100;
                    finalReport(inti).DiffusionAccuracyFinal = (1-round(tmp{4},2))*100;
                    finalReport(inti).LCAAccuracyFinal = (1-round(tmp{6},2))*100;
                    finalReport(inti).RaceAccuracyHalf1Final = (1-round(tmp{7},2))*100;
                    finalReport(inti).RaceAccuracyHalf2Final = (1-round(tmp{8},2))*100;
                    finalReport(inti).DiffusionAccuracyHalf1Final = (1-round(tmp{9},2))*100;
                    finalReport(inti).DiffusionAccuracyHalf2Final = (1-round(tmp{10},2))*100;
                    finalReport(inti).LCAAccuracyHalf1Final = (1-round(tmp{11},2))*100;
                    finalReport(inti).LCAAccuracyHalf2Final = (1-round(tmp{12},2))*100;
                else
                    finalReport(inti).RaceAccuracyFinal = round(tmp{3},2)*100;
                    finalReport(inti).DiffusionAccuracyFinal = round(tmp{4},2)*100;
                    finalReport(inti).LCAAccuracyFinal = round(tmp{6},2)*100;
                    finalReport(inti).RaceAccuracyHalf1Final = round(tmp{7},2)*100;
                    finalReport(inti).RaceAccuracyHalf2Final = round(tmp{8},2)*100;
                    finalReport(inti).DiffusionAccuracyHalf1Final = round(tmp{9},2)*100;
                    finalReport(inti).DiffusionAccuracyHalf2Final = round(tmp{10},2)*100;
                    finalReport(inti).LCAAccuracyHalf1Final = round(tmp{11},2)*100;
                    finalReport(inti).LCAAccuracyHalf2Final = round(tmp{12},2)*100;
                end
            end
            meanAccuracyOfRace = mean([finalReport(:).RaceAccuracyFinal]);
            meanAccuracyOfDiffusion = mean([finalReport(:).DiffusionAccuracyFinal]);
            meanAccuracyOfLCA = mean([finalReport(:).LCAAccuracyFinal]);
            means(parameter).averagedRaceAccuracy = meanAccuracyOfRace;
            means(parameter).averagedDiffusionAccuracy = meanAccuracyOfDiffusion;
            means(parameter).averagedLCAAccuracy = meanAccuracyOfLCA;
            disp("-------Complete Full Analizer on All Subjects for inputs parameters: "+...
                num2str(parameters(parameter,1))+"-"+num2str(parameters(parameter,2))+" and noiseSTD of "+num2str(parameters(parameter,3))+"!--------");
            save(fullfile('100TrialsAnalize',['finalReport_inputs-',num2str(parameters(parameter,1)),'-',num2str(parameters(parameter,2)),'_STD-',num2str(parameters(parameter,3)),'_trialNum',num2str(trialNum),'.mat']),'finalReport');
        end
    end
     save('MeansOfModelsAccuracyWithLeacky.mat','means');
end