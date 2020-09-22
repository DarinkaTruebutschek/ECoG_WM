%This script converts the behavioral data file into a structure so that it
%may be read in with Python
%Project: ECoG_WM
%Author: D.T.
%Date: 14 October 2019

clc;
clear all;
close all;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HL', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};
subnips = {'MKL'};

%% Convert to structure
for subi = 1 : length(subnips)
    
    %Load behavioral file
    load([behavior_path subnips{subi} '_memory_behavior.mat']);
    
    table_struct = struct(data_mem);
    table_columns = table_struct.varDim.labels;
    
    save([behavior_path subnips{subi} '_memory_behavior_forPython.mat'], 'table_struct', 'table_columns');
end