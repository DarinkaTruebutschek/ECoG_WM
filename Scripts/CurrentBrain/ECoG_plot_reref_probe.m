%Purpose: Rereference the epochs to the subjects' response (i.e., RT = 0)
%Project: ECoG_WM
%Author: D.T.
%Date: 09 December 2019

clear all;

close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
%subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP', 'HL'}; %subject KR has a different sampling frequency, to be checked carefully
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP', 'CD', 'HL'};
%subnips = {'SB'};

%% Load data
for subi = 1 : length(subnips)
    
    display(['Preparing subject: ' subnips{subi}]);
    
    %Load initial data
    load([res_path subnips{subi} '/' subnips{subi} '_probeLocked_erp_100.mat']);
    
    %Compute ERP
    cfg = [];
    erp{subi} = ft_timelockanalysis(cfg, data_probeLocked);
    
    %Plot individual subjects' erps
    figure;
    plot(erp{subi}.time, squeeze(mean(erp{subi}.avg)));
    
    pause;
end


