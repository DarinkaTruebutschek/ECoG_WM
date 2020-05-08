%This script adds the full behavioral trialinfo to the rereferenced ECoG
%file
%Project: ECoG_WM
%Author: D.T.
%Date: 26 September 2019

clc;
clear all;
close all;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HL', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};
subnips = {'CD'};

%% Add missing trialInfo
for subi = 1 : length(subnips)
    
    %Load behavioral and ECoG data file
    load([behavior_path subnips{subi} '_memory_behavior.mat']);
    load([res_path '/' subnips{subi} '/' subnips{subi} '_reref.mat']);
    
    %Add complete behavioral data file
    reref.trialInfo_all = data_mem;
    
    %Save
    save([res_path subnips{subi} '/' subnips{subi} '_reref.mat'], 'reref', '-v7.3');
end
    
