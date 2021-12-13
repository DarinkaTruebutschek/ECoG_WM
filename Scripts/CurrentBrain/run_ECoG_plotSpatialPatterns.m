%This script projects the coefficients of the spatial pattern decoding onto
%the mni standard brain.
%Project: ECoG_WM
%Author: D.T.
%Date: 14 Sept 2021

clear all;
close all;
clc;

%% Specify important variables

subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

hemi = 'left';
viewside = 'lateral';
projectToLeft = 1; %project electrodes from the right hemisphere to the left?
normalization = 1; %normalize within-subject or not
maskSigTimes = 1; %mask any non-significant time points (within-subject) & just plot the raw sig scores

%decCond = {'cue_diag', 'itemPos_diag', 'indItems_diag', 'load_diag', 'probeID_diag', 'probe_diag', 'buttonPress_diag'};
decCond = {'indItems_trainCue0_testCue0_diag', 'indItems_trainCue1_testCue1_diag'};
%decCond = {'itemPos_diag'};
filename = 'erp_100_spatialPatterns';
fmethod = 'erp_100';

%Timebins & significant time windows of interest
if strcmp(fmethod, 'erp_100')
    timeBins_labels = {'Baseline', 'Cue', 'Delay 1', 'Items', 'Delay 2'};
    timebins = [-.2, 0; 0, 0.5; 0.5, 1.5; 1.5 2.5; 2.5, 4.5];
%     timebins = [-.2, -.1; -.1, 0; 0, .1; .1, .2; .2, .3; .3, .4; .4, .5; .5, .6; .6, .7; .7, .8; .8, .9; .9, 1.; ...
% 		1., 1.1; 1.1, 1.2; 1.2, 1.3; 1.3, 1.4; 1.4, 1.5; 1.5, 1.6; 1.6, 1.7; 1.7, 1.8; 1.8, 1.9; 1.9, 2.0; ...
% 		2., 2.1; 2.1, 2.2; 2.2, 2.3; 2.3, 2.4; 2.4, 2.5; 2.5, 2.6; 2.6, 2.7; 2.7, 2.8; 2.8, 2.9; 2.9, 3.0; ...
% 		3., 3.1; 3.1, 3.2; 3.2, 3.3; 3.3, 3.4; 3.4, 3.5; 3.5, 3.6; 3.6, 3.7; 3.7, 3.8; 3.8, 3.9; 3.9, 4.0; ...
% 		4., 4.1; 4.1, 4.2; 4.2, 4.3; 4.3, 4.4; 4.4, 4.5];
    timeline = [-0.45 : 0.01 : 4.49];
    if strcmp(decCond, 'cue_diag')
        sigTimes = [0.49, 0.64; 0.76, 0.88];
    elseif strcmp(decCond, 'itemPos_diag')
        sigTimes = [1.71, 3.45];
    elseif strcmp(decCond, 'indItems_diag')
        sigTimes = [1.75, 2.11; 2.13, 2.29; 2.47, 2.56; 2.58, 2.66; 2.68, 2.77; 2.87, 3.04];
    elseif strcmp(decCond, 'load_diag')
        sigTimes = [1.75, 2.55; 2.57, 3.26];
    elseif strcmp(decCond, 'probeID_diag')
    elseif strcmp(decCond, 'probe_diag')
    elseif strcmp(decCond, 'buttonPress_diag')
    end
elseif strcmp(fmethod, 'probeLocked_erp_100_longEpoch')
    timeBins_labels = {'Cue', 'Delay 1', 'Items', 'Delay 2', 'Probe'};
    timebins = [-4.5, -4; -4, -3; -3, -2; -2, 0; 0, 0.5];
%     timebins = [-4.5, -4.4; -4.4, -4.3; -4.3, -4.2; -4.2, -4.1; -4.1, -4.0; ... 
% 		-4.0, -3.9; -3.9, -3.8; -3.8, -3.7; -3.7, -3.6; -3.6, -3.5; -3.5, -3.4; -3.4, -3.3; -3.3, -3.2; -3.2, -3.1; -3.1, -3.0; ...
% 		-3.0, -2.9; -2.9, -2.8; -2.8, -2.7; -2.7, -2.6; -2.6, -2.5; -2.5, -2.4; -2.4, -2.3; -2.3, -2.2; -2.2, -2.1; -2.1, -2.0; ...
% 		-2.0, -1.9; -1.9, -1.8; -1.8, -1.7; -1.7, -1.6; -1.6, -1.5; -1.5, -1.4; -1.4, -1.3; -1.3, -1.2; -1.2, -1.1; -1.1, -1.0; ...
% 		-1.0, -0.9; -0.9, -0.8; -0.8, -0.7; -0.7, -0.6; -0.6, -0.5; -0.5, -0.4; -0.4, -0.3; -0.3, -0.2; -0.2, -0.1; -0.1, 0.0; ...
% 		0.0, 0.1; 0.1, 0.2; 0.2, 0.3; 0.3, 0.4; 0.4, 0.5];
    timeline = [-4.5 : 0.01 : 0.5];
    if strcmp(decCond, 'cue_diag')
        sigTimes = [-4.01, -3.85];
    elseif strcmp(decCond, 'itemPos_diag')
        sigTimes = [-2.83, -1.16; 0.36, 0.5];
    elseif strcmp(decCond, 'indItems_diag') | strcmp(decCond, 'indItems_trainCue0_testCue0_diag') | strcmp(decCond, 'indItems_trainCue1_testCue1_diag')
        sigTimes = [-2.75, -2.39; -2.37, -2.21; -2.04, -1.94; -1.92, -1.73; -1.63, -1.46];
    elseif strcmp(decCond, 'load_diag')
        sigTimes = [-2.75, -1.95; -1.93, -1.36; -0.05, 0.06; 0.27, 0.5];
    elseif strcmp(decCond, 'probeID_diag')
        sigTimes = [0.29, 0.5];
    elseif strcmp(decCond, 'probe_diag')
        sigTimes = [-0.09, -0.03; 0.33, 0.5];
    elseif strcmp(decCond, 'buttonPress_diag')
    end
elseif strcmp(fmethod, 'respLocked_erp_100')
    timebins = [-4, -3.5; -3.5, -3; -3, -2.5; -2.5, -2; -2, -1.5; -1.5, -1; -1, -.5; -.5, 0];
%     timebins = [-4.0, -3.9; -3.9, -3.8; -3.8, -3.7; -3.7, -3.6; -3.6, -3.5; -3.5, -3.4; -3.4, -3.3; -3.3, -3.2; -3.2, -3.1; -3.1, -3.0; ...
% 		-3.0, -2.9; -2.9, -2.8; -2.8, -2.7; -2.7, -2.6; -2.6, -2.5; -2.5, -2.4; -2.4, -2.3; -2.3, -2.2; -2.2, -2.1; -2.1, -2.0; ...
% 		-2.0, -1.9; -1.9, -1.8; -1.8, -1.7; -1.7, -1.6; -1.6, -1.5; -1.5, -1.4; -1.4, -1.3; -1.3, -1.2; -1.2, -1.1; -1.1, -1.0; ...
% 		-1.0, -0.9; -0.9, -0.8; -0.8, -0.7; -0.7, -0.6; -0.6, -0.5; -0.5, -0.4; -0.4, -0.3; -0.3, -0.2; -0.2, -0.1; -0.1, 0.0];
    timeline =  [-4 : 0.01 : 0];
    if strcmp(decCond, 'cue_diag')
        sigTimes = [-0.33, -0.25; -0.14, -0.05];
    elseif strcmp(decCond, 'itemPos_diag')
        sigTimes = [-2.73, -2.61; -0.67, -0.59; -0.52, -0.42; -0.4, -0.18; -0.13, 0.];
    elseif strcmp(decCond, 'indItems_diag')
    elseif strcmp(decCond, 'load_diag')
        sigTimes = [-3.06, -2.94; -2.09, -2.0; -0.65, -0.6; -0.46, -0.35; -0.3, 0.];
    elseif strcmp(decCond, 'probeID_diag')
    elseif strcmp(decCond, 'probe_diag')
        sigTimes = [-0.32, -0.17];
    elseif strcmp(decCond, 'buttonPress_diag')
        sigTimes = [-0.55, 0];
    end
end

%For plotting
%my_colors = flipud(cbrewer('div','Spectral', 12));
%my_colors = cbrewer('seq','PuRd', 12);
my_colors = cbrewer('seq','PuRd', 12);


%% Import necessary paths
ECoG_setPath;

%% Run
for decod_i = 1 : length(decCond)
    ECoG_plotSpatialPatterns(decCond{decod_i}, filename, fmethod);
end
