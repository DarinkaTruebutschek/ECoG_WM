%This script converts the matlab table into a python-readable format
%Project: ECoG_WM
%Author: D.T.
%Date: 05 October 2020

clear all;
clc;
close all;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

%% Loop over subjects 
for subi = 1 : length(subnips)
    load([behavior_path subnips{subi} '_memory_behavior_combined.mat']);
    
    table_struct = struct(data_mem);
    table_columns = table_struct.varDim.labels;
    
    save([behavior_path subnips{subi} '_memory_behavior_forPython_final.mat'], 'table_struct', 'table_columns');
end