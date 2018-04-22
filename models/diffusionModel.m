function [response, RT] = diffusionModel(Diffusion)
t=1;
if Diffusion.StartingPointChanges == true
    X1(1) = Diffusion.StartingPoint1;
    X2(1) = Diffusion.StartingPoint2;
else
    X1(1) = 0;
    X2(1) = 0;
end


while max(X1(t),X2(t)) < Diffusion.Threshold  
    
    Delta1 = Diffusion.Input1 + Diffusion.noise*randn;
    Delta2 = Diffusion.Input2 + Diffusion.noise*randn;
    
    X1(t+1) = X1(t) + Delta1 - Delta2;
    X2(t+1) = X2(t) + Delta2 - Delta1;  
       
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

