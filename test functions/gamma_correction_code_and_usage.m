
%get the screen pointed
whichScreen=max(Screen('Screens'));
%run the psychtoolbox calibration test (9 lluminance levels);
[ gammaTable1, gammaTable2, displayBaseline, displayRange, displayGamma, maxLevel ] = CalibrateMonitorPhotometer(9, whichScreen)

%look at the output graph, change this to gammaTable1, only if the power
%fitting is better than the spline fitting
gammaTable=gammaTable2;
%save the screen's corrected gamma table
save('gammaTable.mat','gammaTable','displayGamma');





%to use corrected values: %load the room's gamme table, and use the
%"loadnormalizedgammatable command after opening the window:
%example code: 

load gammaTable     % <---loading room's corrected gamme table;
whichScreen=max(Screen('Screens'));
[window,rect] = Screen('OpenWindow', whichScreen);
Screen('LoadNormalizedGammaTable', window, gammaTable*[1 1 1]); % <--- tell psychtoolbox to use the corrected values;

