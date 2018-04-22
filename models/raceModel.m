function [response, RT] = raceModel(Race)
t = 1;
if Race.StartingPointChanges == true
    X1(1) = Race.StartingPoint1;
    X2(1) = Race.StartingPoint2;
else
    X1(1) = 0;
    X2(1) = 0;
end

while max(X1(t),X2(t)) < Race.Threshold  
    X1(t+1) = X1(t) + Race.Input1 + Race.noise*randn;
    X2(t+1) = X2(t) + Race.Input2 + Race.noise*randn;    
    t = t+1;
end

%% Response
if X1(t) > X2(t)
    response = 1;
else 
    response = 0;
end

%% RT
RT = t;

end

