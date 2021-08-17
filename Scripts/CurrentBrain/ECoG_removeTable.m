%This script will simply remove the trial table from the frequency
%structure to be able to be imported in Python
%Project: ECoG_WM
%Author: D.T.
%Date: 15 September 2020

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP', 'CD', 'HL'};
subnips = {'HS', 'KJ_I', 'LJ', 'MG', 'WS', 'KR', 'AS', 'AP'};
%subnips = {'AP', 'AS', 'KR', 'WS', 'SB'};

%% Load data and remove field
for subi = 1 : length(subnips)
    load([res_path subnips{subi} '/' subnips{subi} '_temporal_respLocked_erp_100.mat']);
    data_respLocked = rmfield(data_respLocked, 'trialInfo_all');
    save([res_path subnips{subi} '/' subnips{subi} '_temporal_respLocked_erp_100.mat'], 'data_respLocked', '-v7.3');
end

%% Load data and remove field
for subi = 1 : length(subnips)
    load([res_path subnips{subi} '/' subnips{subi} '_temporal_probeLocked_erp_100_longEpoch.mat']);
    data_probeLocked = rmfield(data_probeLocked, 'trialInfo_all');
    save([res_path subnips{subi} '/' subnips{subi} '_temporal_probeLocked_erp_100_longEpoch.mat'], 'data_probeLocked', '-v7.3');
end