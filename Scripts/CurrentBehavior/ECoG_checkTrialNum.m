%This script checks the condition numbers of trials recorded for individual
%subjects.
%Project: ECoG_WM
%Author: D.T.
%Date: 16 September 2020

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP', 'CD', 'HL'}; 
subnips = {'EG_I'};

num_sessions = [];
num_trials = [];
num_trials_inc = [];
num_cue = [];
num_load = [];
num_probe = [];
num_stimA_id = [];
num_stimB_id = [];
num_stimC_id = [];
num_stimD_id = [];
num_probe_id = [];

num_cueMatch_load1 = [];
num_cueMatch_load2 = [];
num_cueMatch_load4 = [];
num_cueMismatch_load1 = [];
num_cueMismatch_load2 = [];
num_cueMismatch_load4 = [];

num_cueMatch_probeMatch = [];
num_cueMatch_probeMismatch = [];
num_cueMatch_probeMatch = [];
num_cueMismatch_probeMismatch = [];

%% Loop over subjects
for subi = 1 : length(subnips)
    load([behavior_path '/' subnips{subi} '_memory_behavior.mat']);
    
    %First, get info on what had been presented
    num_sessions(subi) = max(unique(data_mem.session_id));
    num_trials(subi) = length(data_mem.session_id);
    num_trials_inc(subi) = sum(data_mem.EEG_included);
    num_cue(subi) = sum(data_mem.cue == 1);
    num_load(subi, 1) = sum(data_mem.load == 1);
    num_load(subi, 2) = sum(data_mem.load == 2);
    num_load(subi, 3) = sum(data_mem.load == 4);
    num_probe(subi) = sum(data_mem.probe == 1);
    
    for stimID = 1 : 10
        num_stimA_id(subi, stimID) = sum(data_mem.stimA_id == stimID-1);
        num_stimB_id(subi, stimID) = sum(data_mem.stimB_id == stimID-1);
        num_stimC_id(subi, stimID) = sum(data_mem.stimC_id == stimID-1);
        num_stimD_id(subi, stimID) = sum(data_mem.stimD_id == stimID-1);
        num_probe_id(subi, stimID) = sum(data_mem.probe_id == stimID-1);
    end
    
    %Then, get info on most relevant conditions
    num_cueMatch_load1(subi) = sum(data_mem.EEG_included & data_mem.cue == 0 & data_mem.load == 1);
    num_cueMatch_load2(subi) = sum(data_mem.EEG_included & data_mem.cue == 0 & data_mem.load == 2);
    num_cueMatch_load4(subi) = sum(data_mem.EEG_included & data_mem.cue == 0 & data_mem.load == 4);
    num_cueMismatch_load1(subi) = sum(data_mem.EEG_included & data_mem.cue == 1 & data_mem.load == 1);
    num_cueMismatch_load2(subi) = sum(data_mem.EEG_included & data_mem.cue == 1 & data_mem.load == 2);
    num_cueMismatch_load4(subi) = sum(data_mem.EEG_included & data_mem.cue == 1 & data_mem.load == 4);
    
    num_cueMatch_probeMatch(subi) = sum(data_mem.EEG_included & data_mem.cue == 0 & data_mem.probe == 0); 
    num_cueMatch_probeMismatch(subi) = sum(data_mem.EEG_included & data_mem.cue == 0 & data_mem.probe == 1); 
    num_cueMatch_probeMatch(subi) = sum(data_mem.EEG_included & data_mem.cue == 1 & data_mem.probe == 0); 
    num_cueMismatch_probeMismatch(subi) = sum(data_mem.EEG_included & data_mem.cue == 1 & data_mem.probe == 1); 
end