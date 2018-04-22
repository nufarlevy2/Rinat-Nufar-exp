clear all; clc; close all;
rng(1);

%% Section selection - TO CHANGE IN EACH SECTION
section = 1; % 1 for a, 2 for b and 3 for c

%% General Parameters
pos = 0;
nSimulations = 1e3;
fractions = [0.1, 0.3, 0.5, 0.7, 0.9];

% difficulties
diffLevels = 4;
Difficulties = zeros(2,diffLevels);
Difficulties(1,:) = [0.585,0.5618, 0.533, 0.522];
Difficulties(2,:) = [0.415, 0.4382, 0.467, 0.478];

% results matrixes
response = zeros(1,nSimulations);
RT = zeros(1,nSimulations);
quantilesMat = zeros(2*diffLevels, length(fractions));

%% Diffusion Parameters
Diffusion.noise = 2;
Diffusion.Threshold = 50;

%% Section B definitions for the different parts
STARTING_POINT_VARIABILITY = 1;
DRIFT_VARIABILITY = 2;
BOTH_PARAMETERS_VARIABILITYS = 3;

%% definistions for each section
if section == 1
    Diffusion.StartingPointChanges = false; %False for A section True for B section
    Race.StartingPointChanges = false; %False for A section True for B section
    partsPerSection = 1;
    Race.noise = 2;
    Race.Threshold = 240;
elseif section == 2
    partsPerSection = 3;
    Diffusion.StartingPoints = 0;
    % This is the B parameter part
    Diffusion.InputDeviation = 0.083; % drift deviation
    Diffusion.StartingPointDeviationStart = -38; % starting point start of deviation
    Diffusion.StartingPointDeviationEnd = 38; % starting point end of deviation
    Diffusion.StartingPointChanges = true; % False for A section True for B section
elseif section == 3
    partsPerSection = 4;
    Race.noise = 0;
    % This is the C parameter part
    Race.InputDeviation = 0.1; % drift deviation
    Race.LowStartingPointDeviationStart = 0; % low starting point start of deviation
    Race.LowStartingPointDeviationEnd = 80; % low starting point start of deviation
    Race.HighStartingPointDeviationStart = 81; % high starting point start of deviation
    Race.HighStartingPointDeviationEnd = 161; % high starting point start of deviation
    addingToInput = 0.05; % the second addition to the input
    Race.Threshold = 240;
end

%% RT distribution Diffusion
if section ~=3
    for iPartPerSection = 1:partsPerSection % for each part of each section
        if section == 3 && iPartPerSection == 2 % giving high drift
                    Difficulties(1,:) = Difficulties(1,:) + addingToInput;
                    Difficulties(2,:) = Difficulties(2,:) - addingToInput;
        end
        for level = 1:diffLevels % for each difficulty
            % defualt configurations
            Diffusion.Input1Normal = Difficulties(1,level);
            Diffusion.Input2Normal = Difficulties(2,level);
            Diffusion.StartingPoint1 = 0;
            Diffusion.StartingPoint2 = 0;
            for iSimulation = 1:nSimulations
                % configuring the normal input in section A = 1
                if (section == 1 | (section == 2 & iPartPerSection == STARTING_POINT_VARIABILITY))
                    Diffusion.Input1 = Diffusion.Input1Normal;
                    Diffusion.Input2 = Diffusion.Input2Normal;
                end
                % Giving variability in Drift:
                if (section == 2 & (iPartPerSection == DRIFT_VARIABILITY ...
                        || iPartPerSection == BOTH_PARAMETERS_VARIABILITYS))
                    Diffusion.Input1 = normrnd(Diffusion.Input1Normal,Diffusion.InputDeviation);
                    Diffusion.Input2 = normrnd(Diffusion.Input2Normal,Diffusion.InputDeviation);
                end
                % Giving variability in StartingPoint:
                if (section == 2 & (iPartPerSection == STARTING_POINT_VARIABILITY ...
                        || iPartPerSection == BOTH_PARAMETERS_VARIABILITYS))
                    Diffusion.StartingPoint1 = random('Uniform',Diffusion.StartingPointDeviationStart,...
                        Diffusion.StartingPointDeviationEnd);
                    Diffusion.StartingPoint2 = random('Uniform',Diffusion.StartingPointDeviationStart,...
                        Diffusion.StartingPointDeviationEnd);
                end
                [response(1,iSimulation), RT(1,iSimulation)] = diffusionModel(Diffusion);
            end
            % Histograms for section A
            if section == 1
                if pos <= 3
                    figure('position',[(10+(310*pos)) 50 307 250]);
                elseif pos > 3 && section == 1
                    figure('position',[(10+(310*(pos-4))) 385 307 250]);
                end
                histPlot(RT, response, 'Diffusion', level);
                pos = pos + 1;
            end
            % Quantiles plots for all sections
            quantilesMat(level,:) = quantile(RT(response == 1),fractions);
            quantilesMat((2*diffLevels+1)-level,:) = quantile(RT(response == 0),fractions);
        end
        if section == 3 && iPartPerSection == 2 % reverting to the origin drift
                    Difficulties(1,:) = Difficulties(1,:) - addingToInput;
                    Difficulties(2,:) = Difficulties(2,:) + addingToInput;
        end
        quantilePlot(quantilesMat', 'Diffusion', length(fractions), section, iPartPerSection);
    end
end

%% RT distributions Race
if section ~= 2
    for iPartPerSection = 1:partsPerSection % for each part of each section
        if section == 3 && iPartPerSection == 2 % giving high drift
            Difficulties(1,:) = Difficulties(1,:) + addingToInput;
            Difficulties(2,:) = Difficulties(2,:) - addingToInput;
        end
        for level = 1:diffLevels % for each difficulty
            Race.Input1Normal = Difficulties(1,level);
            Race.Input2Normal = Difficulties(2,level);
            for iSimulation = 1:nSimulations
                % configuring the normal input in section A = 1
                if (section == 1 | (section == 3 && iPartPerSection > 2))
                    Race.Input1 = Race.Input1Normal;
                    Race.Input2 = Race.Input2Normal;
                end
                % Giving variability in Drift and in StartingPoint:
                if section == 3 && iPartPerSection <= 2
                    Race.Input1 = normrnd(Race.Input1Normal,Race.InputDeviation);
                    Race.Input2 = normrnd(Race.Input2Normal,Race.InputDeviation);
                    Race.StartingPointChanges = false;
                elseif section == 3 && iPartPerSection == 3
                    Race.StartingPoint1 = random('Uniform', Race.LowStartingPointDeviationStart, ...
                        Race.LowStartingPointDeviationEnd);
                    Race.StartingPoint2 = random('Uniform', Race.LowStartingPointDeviationStart, ...
                        Race.LowStartingPointDeviationEnd);
                    Race.StartingPointChanges = true;
                elseif section == 3 && iPartPerSection == 4
                    Race.StartingPoint1 = random('Uniform', Race.HighStartingPointDeviationStart, ...
                        Race.HighStartingPointDeviationEnd);
                    Race.StartingPoint2 = random('Uniform', Race.HighStartingPointDeviationStart, ...
                        Race.HighStartingPointDeviationEnd);
                    Race.StartingPointChanges = true;
                end
                [response(1,iSimulation), RT(1,iSimulation)] = raceModel(Race);
            end
            % Histograms for section A
            if section == 1
                if pos <=3
                    figure('position',[(10+(310*pos)) 50 307 250]);
                else
                    figure('position',[(10+(310*(pos-4))) 303 307 250]);
                end
                histPlot(RT, response, 'Race', level);
                pos = pos + 1;
            end
            % Quantiles plots for all sections
            quantilesMat(level,:) = quantile(RT(response == 1),fractions);
            quantilesMat((2*diffLevels)+1-level,:) = quantile(RT(response == 0),fractions);
        end
        if section == 3 && iPartPerSection == 2 % reverting to the drift origin
                Difficulties(1,:) = Difficulties(1,:) - addingToInput;
                Difficulties(2,:) = Difficulties(2,:) + addingToInput;
        end
        quantilePlot(quantilesMat', 'Race', length(fractions), section, iPartPerSection); 
    end
end


%% Histograms
function histPlot(RT, response, modelName, level)
    width =  max(RT)/20;
    hold on
    histogram(RT(response==1), 'BinWidth',width);
    histogram(RT(response==0), 'BinWidth',width);
    title([modelName ' Histogram of level ', num2str(level)]);
    xlabel('Time', 'FontSize', 12);
    ylabel('Frequency', 'FontSize', 12);
    hold off
end

%% Latency-quantile plots
function quantilePlot(Mat, modelName, len, section, iPartPerSection)
    % figures position
    if section == 1
        if strcmp(modelName,'Race') 
            figure('position',[(100+470) 200 467 400]);
        else
            figure('position',[100 200 467 400]);
        end
    elseif section == 2
        figure('position',[(10+(420*(iPartPerSection-1))) 200 417 400]);
    elseif section == 3
        figure('position',[(10+(300*(iPartPerSection-1))) 250 297 300]);
    end
    hold on
    for k=1:len
        plot([0.9 0.8 0.7 0.6 0.4 0.3 0.2 0.1],Mat(k,:), '-x');
    end
    xlim([0 1]);
    xlabel(['\leftarrow Errors  |  Correct \rightarrow' newline '         Difficulty        ']);
    ylabel('Response Time (RT)');
    % figures title
    if section == 1
        title(['Latency Quantile plot: ' modelName ' model']);
    elseif section == 2
        if iPartPerSection == 1
            title('Diffusion model with startingPoint variability', 'Fontsize',10);
        elseif iPartPerSection == 2
            title('Diffusion model with drift variability', 'Fontsize',10);
        else
            title('Diffusion model with both drift and startingPoint variability', 'Fontsize',10);
        end
    elseif section == 3
        if iPartPerSection == 1
            title('LBA model with variability in low drift', 'Fontsize',9);
        elseif iPartPerSection == 2
            title('LBA model with variability in high drift', 'Fontsize',9);
        elseif iPartPerSection == 3
            title('LBA model with variability in low startingPoint', 'Fontsize',9);
        else
            title('LBA model with variability in high startingPoint', 'Fontsize',9);
        end
    end
    leg = legend('10%', '30%', '50%', '70%', '90%');
    set(gca,'FontSize',9, 'FontName', 'David');
    title(leg, 'quantiles');
    hold off
end