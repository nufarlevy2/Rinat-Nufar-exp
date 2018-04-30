function competeAnalyzeForNumOfSubject()
%     prompt = 'Please enter the numbers of all subjects seperated with - ",": ';
%     subjectNumbersTemp = input(prompt,'s');
%     subjectNumbers = strsplit(subjectNumbersTemp,",");
    subjectNumbers = {'100', '105', '107', '108', '110', '113', '115', '116', '117'};
%    subjectNumbers = {'100'};
    means.primaryInput = 0;
    means.secondaryInput = 0;
    len = length(subjectNumbers);
%     parameters = [[0.9,0.1]];
    parameters = [[1,0];[0.95,0.05];[0.9,0.1];[0.85,0.15];[0.8,0.2]];
    for parameter = 1:length(parameters(:,1)) 
        Race.Threshold = 2500;
        Race.primaryInput = parameters(parameter,1);
        Race.SecondaryInput = parameters(parameter,2);
        Race.noiseM = 0;
        Race.noiseSTD = 0.7;
        Diffusion.Threshold = 2000;
        Diffusion.primaryInput = parameters(parameter,1);
        Diffusion.SecondaryInput = parameters(parameter,2);
        Diffusion.noiseM = 0;
        Diffusion.noiseSTD = 0.7; 
        means(parameter).primaryInput = Race.primaryInput;
        means(parameter).secondaryInput = Race.SecondaryInput;
        means(parameter).noiseM = Race.noiseM;
        means(parameter).noiseSTD = Race.noiseSTD;
        means(parameter).RaceThreshold = Race.Threshold;
        means(parameter).DiffusionThreshold = Diffusion.Threshold;
        for inti = 1:len
            tmp = CompleteAnalyze(subjectNumbers{inti},Race, Diffusion);
            finalReport(inti).subjectNumber = str2double(tmp{1});
            finalReport(inti).ReliablePrecentage = round(tmp{2},2);
            finalReport(inti).RaceAccuracy = round(tmp{3},2);
            finalReport(inti).DiffusionAccuracy = round(tmp{4},2);
        end
        meanAccuracyOfRace = mean([finalReport(:).RaceAccuracy]);
        meanAccuracyOfDiffusion = mean([finalReport(:).DiffusionAccuracy]);
        means(parameter).averagedRaceAccuracy = meanAccuracyOfRace;
        means(parameter).averagedDiffusionAccuracy = meanAccuracyOfDiffusion;
        disp("-------Complete Full Analizer on All Subjects for Parameter "+...
            num2str(parameters(parameter,1))+"-"+num2str(parameters(parameter,2))+"--------");
        save(['finalReport_',num2str(parameters(parameter,1)),'-',num2str(parameters(parameter,2)),'.mat'],'finalReport');
    end
     save('MeansOfModelsAccuracy.mat','means');
end