function competeAnalyzeForNumOfSubject()
%     prompt = 'Please enter the numbers of all subjects seperated with - ",": ';
%     subjectNumbersTemp = input(prompt,'s');
%     subjectNumbers = strsplit(subjectNumbersTemp,",");
    subjectNumbers = {'100', '105', '107', '108', '110', '113', '115', '116', '117'};
%    subjectNumbers = {'117'};
    means.primaryInput = 0;
    means.secondaryInput = 0;
    len = length(subjectNumbers);
%    parameters = [[0.95,0.05,0.3]];
    parameters = [[1,0,0.3];[0.95,0.05,0.3];[0.9,0.1,0.3];[0.85,0.15,0.3];[0.8,0.2,0.3];[1,0,0.5];[0.95,0.05,0.5];[0.9,0.1,0.5];[0.85,0.15,0.5];[0.8,0.2,0.5]];
    for parameter = 1:length(parameters(:,1)) 
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
        for inti = 1:len
            tmp = CompleteAnalyze(subjectNumbers{inti},Race, Diffusion);
            finalReport(inti).subjectNumber = str2double(tmp{1});
            finalReport(inti).RankMatchesModelsOtherDirectionPresentage = round(tmp{5},2);
            finalReport(inti).ReliablePrecentage = round(tmp{2},2);
            finalReport(inti).RaceAccuracyOrigin = round(tmp{3},2);
            finalReport(inti).DiffusionAccuracyOrigin = round(tmp{4},2);
            if round(tmp{3},2) < 0.48 && round(tmp{4},2) < 0.48
                finalReport(inti).RaceAccuracyFinal = (1-round(tmp{3},2))*100;
                finalReport(inti).DiffusionAccuracyFinal = (1-round(tmp{4},2))*100;
            else
                finalReport(inti).RaceAccuracyFinal = round(tmp{3},2)*100;
                finalReport(inti).DiffusionAccuracyFinal = round(tmp{4},2)*100;
            end
        end
        meanAccuracyOfRace = mean([finalReport(:).RaceAccuracyFinal]);
        meanAccuracyOfDiffusion = mean([finalReport(:).DiffusionAccuracyFinal]);
        means(parameter).averagedRaceAccuracy = meanAccuracyOfRace;
        means(parameter).averagedDiffusionAccuracy = meanAccuracyOfDiffusion;
        disp("-------Complete Full Analizer on All Subjects for inputs parameters: "+...
            num2str(parameters(parameter,1))+"-"+num2str(parameters(parameter,2))+" and noiseSTD of "+num2str(parameters(parameter,3))+"!--------");
        save(['finalReport_inputs-',num2str(parameters(parameter,1)),'-',num2str(parameters(parameter,2)),'_STD-',num2str(parameters(parameter,3)),'.mat'],'finalReport');
        
    end
    
     save('MeansOfModelsAccuracy.mat','means');
end