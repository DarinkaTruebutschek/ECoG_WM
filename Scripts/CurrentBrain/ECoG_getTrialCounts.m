%Determine whether one can also build 1 "super-subject" (with exactly the
%same trials)
%Project: ECoG_WM
%Author: D.T.
%Date: 18 May 2021

clc;
clear all;
close all;

%% %% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

%% Load data of all subjects
for subi = 1 : length(subnips)
    tmp{subi} = load([behavior_path subnips{subi} '_memory_behavior_combined.mat']);
end

%% Determine how many  load 1 trials there exist for different combinations of item identities and task cue conditions
for subi = 1 : length(subnips)
    
    for identi = 1 : 10
        match_load1{subi}(identi) = sum((tmp{subi}.data_mem.EEG_included == 1) & (tmp{subi}.data_mem.load == 1) &  (tmp{subi}.data_mem.cue == 0) & ...
            (tmp{subi}.data_mem.stimA_id == identi-1) & (tmp{subi}.data_mem.resp == 1 | tmp{subi}.data_mem.resp == 3));
        mismatch_load1{subi}(identi) = sum(((tmp{subi}.data_mem.EEG_included == 1) & tmp{subi}.data_mem.load == 1) &  (tmp{subi}.data_mem.cue == 1) & ...
            (tmp{subi}.data_mem.stimA_id == identi-1) & (tmp{subi}.data_mem.resp == 1 | tmp{subi}.data_mem.resp == 3));
    end
end
        