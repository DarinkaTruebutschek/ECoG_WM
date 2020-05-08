%This script checks the minimum epoch length available for data analysis.
%Project: ECoG_WM
%Author: D.T.
%Date: 16 October 2019

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP', 'HL'};
subnips = {'CD'};

%% Check min epch length
for subi = 1 : length(subnips)
    
     %Load initial data
     load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']);
     
     %Extract epoch length for any given trial
     for triali = 1 : length(reref.time)
         tmp_min(triali) = min(reref.time{triali});
         time_min(subi, triali) = min(reref.time{triali});
         
         tmp_max(triali) = max(reref.time{triali});
         time_max(subi, triali) = max(reref.time{triali});
     end
     
     display(num2str(min(tmp_min)));
     display(num2str(min(tmp_max)));
end

shortestDuration = min(min(time_max(time_max > 0)));
longestDuration = max(max(time_min(time_min < 0)));     
     