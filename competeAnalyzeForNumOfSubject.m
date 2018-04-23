function competeAnalyzeForNumOfSubject()
%     prompt = 'Please enter the numbers of all subjects seperated with - ",": ';
%     subjectNumbersTemp = input(prompt,'s');
%     subjectNumbers = strsplit(subjectNumbersTemp,",");
    subjectNumbers = {'100', '105', '107', '108', '110', '113', '115', '116', '117'};
    means.primaryInput = 0;
    means.secondaryInput = 0;
    means.averagedAccuracy = 0;
    len = length(subjectNumbers);
    parameters = [[0.9,0.1]];
%     parameters = [[0.9,0.1];[0.8,0.2];[0.7,0.3];[0.6,0.4];[0.55,0.45]];
    for parameter = 1:length(parameters(:,1)) 
        Race.Threshold = 2500;
        Race.primaryInput = parameters(parameter,1);
        Race.SecondaryInput = parameters(parameter,2);
        Race.noiseM = 0;
        Race.noiseSTD = 0.7;
        means(parameter).primaryInput = Race.primaryInput;
        means(parameter).secondaryInput = Race.SecondaryInput;
        for inti = 1:len
            tmp = CompleteAnalyze(subjectNumbers{inti},Race);
            finalReport(inti).subjectNumber = str2double(tmp{1});
            finalReport(inti).ReliablePrecentage = round(tmp{2},2);
            finalReport(inti).RaceAccuracy = round(tmp{3},2);
        end
        meanAccuracyOfRace = mean([finalReport(:).RaceAccuracy]);
        Race.meanAccuracyOfRace = meanAccuracyOfRace;
        means(parameter).averagedAccuracy = Race.meanAccuracyOfRace;
        disp("-------Complete Full Analizer on All Subjects--------");
        save(['finalReport_',num2str(parameters(parameter,1)),'-',num2str(parameters(parameter,2))],'-struct','finalReport');    
    end
    save('MeansOfRaceAccuracy','-struct','means');
end