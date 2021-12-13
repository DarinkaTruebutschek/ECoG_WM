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

%% Build "super subject" with strictly identical trials
trials_included = cell(1, 11);
for subi = 1 : length(subnips)
    trials_included{subi} = zeros(1, length(tmp{subi}.data_mem.cue));
    trials_included{subi}(trials_included{subi} == 0) = nan;
end


for triali = 1 : 800
    
    %Extract all relevant variables from the first subject
    cue = tmp{1}.data_mem.cue(triali);
    probe = tmp{1}.data_mem.probe(triali);
    load = tmp{1}.data_mem.load(triali);
    stimA_id = tmp{1}.data_mem.stimA_id(triali);
    stimB_id = tmp{1}.data_mem.stimB_id(triali);
    stimC_id = tmp{1}.data_mem.stimC_id(triali);
    stimD_id = tmp{1}.data_mem.stimD_id(triali);
    probe_id = tmp{1}.data_mem.probe_id(triali);
    resp = tmp{1}.data_mem.resp(triali);
    RT_included = tmp{1}.data_mem.RT_included(triali);
    timing = tmp{1}.data_mem.timing(triali);
    EEG_included = tmp{1}.data_mem.EEG_included(triali);
    stimA_angle = tmp{1}.data_mem.stimA_angle(triali);
    stimB_angle = tmp{1}.data_mem.stimB_angle(triali);
    stimC_angle = tmp{1}.data_mem.stimC_angle(triali);
    stimD_angle = tmp{1}.data_mem.stimD_angle(triali);
    
    %Check whether this very same combination also exists for all other
    %subjects
    n_subs_incl = 0;
    
    for subi = 2 : 11
        %display(['Checking subject ' num2str(subi)]);
        for triali_2 = 1 : length(tmp{subi}.data_mem.cue)
            if isnan(trials_included{subi}(triali_2))
                if (cue == tmp{subi}.data_mem.cue(triali_2) && ...
                    probe == tmp{subi}.data_mem.probe(triali_2) && ...
                    load == tmp{subi}.data_mem.load(triali_2) && ...
                    stimA_id == tmp{subi}.data_mem.stimA_id(triali_2) && ...
                    stimB_id == tmp{subi}.data_mem.stimB_id(triali_2) && ...
                    stimC_id == tmp{subi}.data_mem.stimC_id(triali_2) && ...
                    stimD_id == tmp{subi}.data_mem.stimD_id(triali_2) && ...
                    probe_id == tmp{subi}.data_mem.probe_id(triali_2) && ...
                    resp == tmp{subi}.data_mem.resp(triali_2) && ...
                    RT_included == tmp{subi}.data_mem.RT_included(triali_2) && ...
                    timing == tmp{subi}.data_mem.timing(triali_2) && ...
                    EEG_included == tmp{subi}.data_mem.EEG_included(triali_2) && ...
                    stimA_angle == tmp{subi}.data_mem.stimA_angle(triali_2) && ...
                    stimB_angle == tmp{subi}.data_mem.stimB_angle(triali_2) && ...
                    stimC_angle == tmp{subi}.data_mem.stimC_angle(triali_2) && ...
                    stimD_angle == tmp{subi}.data_mem.stimD_angle(triali_2))
                
                    trials_included{subi}(triali_2) = triali_2;
                
                    display(['Compatibility found for subject ' num2str(subi) ' and trial ' num2str(triali_2)]);
                    display(num2str(trials_included{subi}(triali_2)));
                
                    n_subs_incl = n_subs_incl + 1;
                end
            end
        end
    end
    
    if n_subs_incl == 10
        common_trials(triali) = 1;
    else
        common_trials(triali) = 0;
    end
end
