function [ result ] = data2models( left, right, Race, Diffusion, LCA)
    %% Race
    X1(1) = 0;
    X2(1) = 0;
    t = 1;
    leftIndex = 1;
    rightIndex = 1;
    
    while ((max(X1(t),X2(t)) < Race.Threshold) && (leftIndex <= length(left(:,1))) ...
            && (rightIndex <= length(right(:,1))))
        if (t >= left(leftIndex,1) && t <= left(leftIndex,1)+left(leftIndex,2))
            leftInput = Race.primaryInput;
            rightInput = Race.SecondaryInput;
        elseif (t >= right(rightIndex,1) && t <= right(rightIndex,1)+right(rightIndex,2))
            rightInput = Race.primaryInput;
            leftInput = Race.SecondaryInput;
        else
            leftInput = 0;
            rightInput = 0;
        end
        if (t > (left(leftIndex,1)+left(leftIndex,2)))
            leftIndex = leftIndex + 1;
        end
        if (t > (right(rightIndex,1)+right(rightIndex,2)))
            rightIndex = rightIndex + 1;
        end
        X1(t+1) = X1(t) + leftInput + normrnd(Race.noiseM, Race.noiseSTD);
        X2(t+1) = X2(t) + rightInput + normrnd(Race.noiseM, Race.noiseSTD);
        t = t+1;
    end
    while ((max(X1(t),X2(t)) < Race.Threshold) && rightIndex <= length(right(:,1)))
        if (t >= right(rightIndex,1) && t <= right(rightIndex,1)+right(rightIndex,2))
            rightInput = Race.primaryInput;
            leftInput = Race.SecondaryInput;
        else
            leftInput = 0;
            rightInput = 0;
        end
        if (t > (right(rightIndex,1)+right(rightIndex,2)))
            rightIndex = rightIndex + 1;
        end
        X1(t+1) = X1(t) + leftInput + normrnd(Race.noiseM, Race.noiseSTD);
        X2(t+1) = X2(t) + rightInput + normrnd(Race.noiseM, Race.noiseSTD);
        t = t+1;
    end
    while ((max(X1(t),X2(t)) < Race.Threshold) && leftIndex <= length(left(:,1)))
        if (t >= left(leftIndex,1) && t <= left(leftIndex,1)+left(leftIndex,2))
            leftInput = Race.primaryInput;
            rightInput = Race.SecondaryInput;
        else
            leftInput = 0;
            rightInput = 0;
        end
        if (t > (left(leftIndex,1)+left(leftIndex,2)))
            leftIndex = leftIndex + 1;
        end
        X1(t+1) = X1(t) + leftInput + normrnd(Race.noiseM, Race.noiseSTD);
        X2(t+1) = X2(t) + rightInput + normrnd(Race.noiseM, Race.noiseSTD);
        t = t+1;
    end
    %% Response
    if X1(t) > X2(t)
        result(1) = 0;
    else 
        result(1) = 1;
    end

    %% RT
    result(2) = t;

    
    %% Difusion
    X1(1) = 0;
    X2(1) = 0;
    t = 1;
    leftIndex = 1;
    rightIndex = 1;
    
    while ((max(X1(t),X2(t)) < Diffusion.Threshold) && (leftIndex <= length(left(:,1))) ...
            && (rightIndex <= length(right(:,1))))
        if (t >= left(leftIndex,1) && t <= left(leftIndex,1)+left(leftIndex,2))
            leftInput = Diffusion.primaryInput;
            rightInput = Diffusion.SecondaryInput;
        elseif (t >= right(rightIndex,1) && t <= right(rightIndex,1)+right(rightIndex,2))
            rightInput = Diffusion.primaryInput;
            leftInput = Diffusion.SecondaryInput;
        else
            leftInput = 0;
            rightInput = 0;
        end
        if (t > (left(leftIndex,1)+left(leftIndex,2)))
            leftIndex = leftIndex + 1;
        end
        if (t > (right(rightIndex,1)+right(rightIndex,2)))
            rightIndex = rightIndex + 1;
        end
        Delta1 = leftInput + normrnd(Diffusion.noiseM, Diffusion.noiseSTD);
        Delta2 = rightInput + normrnd(Diffusion.noiseM, Diffusion.noiseSTD);
        X1(t+1) = X1(t) + Delta1 - Delta2;
        X2(t+1) = X2(t) + Delta2 - Delta1;
        t = t+1;
    end
    while ((max(X1(t),X2(t)) < Diffusion.Threshold) && rightIndex <= length(right(:,1)))
        if (t >= right(rightIndex,1) && t <= right(rightIndex,1)+right(rightIndex,2))
            rightInput = Diffusion.primaryInput;
            leftInput = Diffusion.SecondaryInput;
        else
            leftInput = 0;
            rightInput = 0;
        end
        if (t > (right(rightIndex,1)+right(rightIndex,2)))
            rightIndex = rightIndex + 1;
        end
        Delta1 = leftInput + normrnd(Diffusion.noiseM, Diffusion.noiseSTD);
        Delta2 = rightInput + normrnd(Diffusion.noiseM, Diffusion.noiseSTD);
        X1(t+1) = X1(t) + Delta1 - Delta2;
        X2(t+1) = X2(t) + Delta2 - Delta1;
        t = t+1;
    end
    while ((max(X1(t),X2(t)) < Diffusion.Threshold) && leftIndex <= length(left(:,1)))
        if (t >= left(leftIndex,1) && t <= left(leftIndex,1)+left(leftIndex,2))
            leftInput = Diffusion.primaryInput;
            rightInput = Diffusion.SecondaryInput;
        else
            leftInput = 0;
            rightInput = 0;
        end
        if (t > (left(leftIndex,1)+left(leftIndex,2)))
            leftIndex = leftIndex + 1;
        end
        Delta1 = leftInput + normrnd(Diffusion.noiseM, Diffusion.noiseSTD);
        Delta2 = rightInput + normrnd(Diffusion.noiseM, Diffusion.noiseSTD);
        X1(t+1) = X1(t) + Delta1 - Delta2;
        X2(t+1) = X2(t) + Delta2 - Delta1;
        t = t+1;
    end
    %% Response
    if X1(t) > X2(t)
        result(3) = 0;
    else 
        result(3) = 1;
    end

    %% RT
    result(4) = t;
    
    %% Leaky Model
    X1(1) = 0;
    X2(1) = 0;
    t = 1;
    leftIndex = 1;
    rightIndex = 1;
    while ((max(X1(t),X2(t)) < LCA.Threshold) && (leftIndex <= length(left(:,1))) ...
            && (rightIndex <= length(right(:,1))))
        if (t >= left(leftIndex,1) && t <= left(leftIndex,1)+left(leftIndex,2))
            leftInput = LCA.primaryInput;
            rightInput = LCA.SecondaryInput;
        elseif (t >= right(rightIndex,1) && t <= right(rightIndex,1)+right(rightIndex,2))
            rightInput = LCA.primaryInput;
            leftInput = LCA.SecondaryInput;
        else
            leftInput = 0;
            rightInput = 0;
        end
        if (t > (left(leftIndex,1)+left(leftIndex,2)))
            leftIndex = leftIndex + 1;
        end
        if (t > (right(rightIndex,1)+right(rightIndex,2)))
            rightIndex = rightIndex + 1;
        end
        X1(t+1) = (1 - LCA.Leak) * X1(t) + leftInput + normrnd(LCA.noiseM, LCA.noiseSTD) - LCA.Inhibition*X2(t);
        X2(t+1) = (1 - LCA.Leak) * X2(t) + rightInput + normrnd(LCA.noiseM, LCA.noiseSTD) - LCA.Inhibition*X1(t);
        % Non-Linearity
        if X1(t+1) < 0
            X1(t+1) = 0;
        end
        if X2(t+1) < 0
            X2(t+1) = 0;
        end
        t = t+1;
    end
    while ((max(X1(t),X2(t)) < LCA.Threshold) && rightIndex <= length(right(:,1)))
        if (t >= right(rightIndex,1) && t <= right(rightIndex,1)+right(rightIndex,2))
            rightInput = LCA.primaryInput;
            leftInput = LCA.SecondaryInput;
        else
            leftInput = 0;
            rightInput = 0;
        end
        if (t > (right(rightIndex,1)+right(rightIndex,2)))
            rightIndex = rightIndex + 1;
        end
        X1(t+1) = (1 - LCA.Leak) * X1(t) + leftInput + normrnd(LCA.noiseM, LCA.noiseSTD) - LCA.Inhibition*X2(t);
        X2(t+1) = (1 - LCA.Leak) * X2(t) + rightInput + normrnd(LCA.noiseM, LCA.noiseSTD) - LCA.Inhibition*X1(t);
        % Non-Linearity
        if X1(t+1) < 0
            X1(t+1) = 0;
        end
        if X2(t+1) < 0
            X2(t+1) = 0;
        end
        t = t+1;
    end
    while ((max(X1(t),X2(t)) < LCA.Threshold) && leftIndex <= length(left(:,1)))
        if (t >= left(leftIndex,1) && t <= left(leftIndex,1)+left(leftIndex,2))
            leftInput = LCA.primaryInput;
            rightInput = LCA.SecondaryInput;
        else
            leftInput = 0;
            rightInput = 0;
        end
        if (t > (left(leftIndex,1)+left(leftIndex,2)))
            leftIndex = leftIndex + 1;
        end
        X1(t+1) = (1 - LCA.Leak) * X1(t) + leftInput + normrnd(LCA.noiseM, LCA.noiseSTD) - LCA.Inhibition*X2(t);
        X2(t+1) = (1 - LCA.Leak) * X2(t) + rightInput + normrnd(LCA.noiseM, LCA.noiseSTD) - LCA.Inhibition*X1(t);
        % Non-Linearity
        if X1(t+1) < 0
            X1(t+1) = 0;
        end
        if X2(t+1) < 0
            X2(t+1) = 0;
        end
        t = t+1;
    end
    %% Response
    if X1(t) > X2(t)
        result(5) = 0;
    else
        result(5) = 1;
    end

    %% RT
    result(6) = t;
end