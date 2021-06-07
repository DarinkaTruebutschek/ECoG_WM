%This script orders the channels along an anterior-posterior axis and saves
%the output for import to Python
%Project: ECoG_WM
%Author: D.T.
%Date: 21 May 2021

clear all;
close all;
clc;

%% Import necessary paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};

sort_direction = 'ant-post';

%% Loop over subjects
for subi = 1 : length(subnips)
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']); %load preprocessed data including the necessary channel information
    
    %Extract channel info
    channels = reref.elec.chanpos;
    clear('reref');
    
    %Sort
    [~, sortIndex] = sort(channels(:, 2), 'descend');
    channels_sorted = channels(sortIndex, :);
    
    %Save
    save([res_path subnips{subi} '/' subnips{subi} '_sortedChannels.mat'], 'channels', 'channels_sorted', 'sortIndex');
end