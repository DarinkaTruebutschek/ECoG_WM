%This is the main script to run the entire behavioral analysis pipeline.
%Project: ECoG_WM
%Author: D.T.
%Date: 13 March 2019

clear all; 
close all;
clc;

%% Add relevant paths
dat_path = '/home/dante/Desktop/iEEG/';
res_path = '/home/dante/Desktop/iEEG/Results/';
script_path = '/home/dante/Desktop/iEEG/ECoG_WM/Scripts/CurrentBehavior/';
toolbox_path = '/home/dante/Desktop/iEEG/ECoG_WM/Scripts/Toolboxes/';

addpath(script_path);
addpath(toolbox_path);

%% Define important variables
subnips = {'MKL','EG_I','HS','MG','KR','WS','KJ_I','LJ','AS','SB','HL','AP'}; %all subjects included in analysis
condition = 'memory';

%% Extract behavioral data from original files and save as a .mat file
for subi = 1 : length(subnips)
    
    res_filename_mem = [subnips{subi} '_memory_behavior.mat'];
    res_filename_reward = [subnips{subi} '_reward_behavior.mat'];
    
    %Check whether data have already been preprocessed, if so, skip this
    %subject
    if exist([res_path res_filename_mem])
        continue
    end
    
    disp(['Preprocessing behavioral data for subject: ' subnips{subi}]);
    
    %Specify exact filenames to be loaded for each inividual subject
    switch char(subnips{subi})
        case 'MKL'
            dirname = [dat_path subnips{subi} '/logs/'];
        case 'EG_I'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'HS'
            dirname = [dat_path subnips{subi} '/logs/'];
        case 'MG'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'KR'
            dirname = [dat_path subnips{subi} '/logs/'];
        case 'WS'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'KJ_I'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'LJ'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'AS'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'SB'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'HL'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'AP'
            dirname = [dat_path subnips{subi} '/Explogs/'];
    end

    [data_mem, data_reward] = ECoG_getBehavior(dirname);
    
    %Save data
    save([res_path res_filename_mem], 'data_mem');
    save([res_path res_filename_reward], 'data_reward');  
end

%% Get general idea of number of trials/condition
for subi = 1 : length(subnips)
    
    load([res_path subnips{subi} '_' condition '_behavior.mat']);
    
    no_rule{subi} = ECoG_getTrialCount([data_mem.cue, data_mem.RT_included, data_mem.timing], 'rule'); %get # of trials per rule condition
    no_load{subi} = ECoG_getTrialCount([data_mem.load, data_mem.RT_included, data_mem.timing], 'load'); %get # of trials per load condition
    no_stimID{subi} = ECoG_getTrialCount([data_mem.stimA_id, data_mem.stimB_id, data_mem.stimC_id, data_mem.stimD_id, data_mem.RT_included, data_mem.timing], 'stimID'); %get # of trials a given stimulus ID was shown (collapsed across load)
    no_rule_stimID{subi} = ECoG_getTrialCount([data_mem.cue, data_mem.stimA_id, data_mem.stimB_id, data_mem.stimC_id, data_mem.stimD_id, data_mem.RT_included, data_mem.timing], 'rule_stimID'); %get # of trials a given stimulus ID was shown per rule condition
    
    %Plot inividual data
    plotPrettyBar(no_rule{subi}, cbrewer('qual', 'Pastel1', 10), [], [], {'', 'Rule 1', 'Rule 2', ''});
    plotPrettyBar(no_load{subi}, cbrewer('qual', 'Pastel1', 10), [], [], {'', 'Load 1', 'Load 2', 'Load 3', ''});
end