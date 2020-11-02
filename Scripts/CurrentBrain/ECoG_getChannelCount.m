%Purpose: This script calculates the number of channels recorded
%from/included per subject.
%Project: ECoG_WM
%Author: Darinka Truebutschek
%Date: 28 September 2020

clear all;
clc;
close all;

%% Path
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

allChannels = [];
includedChannels = [];

%% Extract channel numbers
for subi = 1 : length(subnips)
    
    load([res_path subnips{subi} '/' subnips{subi} '_epoched.mat']);
    allChannels(subi) = length(data_epoched.label);
    clear('data_epoched');
    
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']);
    includedChannels(subi) = length(reref.label);
    clear('reref');
end

%% Group averages
total_allChannels = sum(allChannels);
mean_allChannels = mean(allChannels);
std_allChannels = std(allChannels);

total_includedChannels = sum(includedChannels);
mean_includedChannels = mean(includedChannels);
std_includedChannels = std(includedChannels);

%% Percent exclusion
my_diff = allChannels - includedChannels;
percent_excluded = my_diff ./ allChannels;

mean_percent_excluded = mean(percent_excluded);
std_percent_excluded = std(percent_excluded);
