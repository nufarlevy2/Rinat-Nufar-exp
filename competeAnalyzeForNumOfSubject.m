function competeAnalyzeForNumOfSubject()
    prompt = 'Please enter the numbers of all subjects seperated with - ",": ';
    subjectNumbersTemp = input(prompt,'s');
    subjectNumbers = strsplit(subjectNumbersTemp,",");
    len = length(subjectNumbers);
    for inti = 1:len
        tmp = CompleteAnalyze(subjectNumbers{inti});
        finalReport(inti).subjectNumber = str2double(tmp{1});
        finalReport(inti).ReliablePrecentage = round(tmp{2},2);
        finalReport(inti).RaceAccuracy = round(tmp{3},2);
    end
    save('finalReport');
end