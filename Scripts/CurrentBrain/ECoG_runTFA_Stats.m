%This script performs a cluster-based permutation test for the final TFA
%analysis.
%Project: ECoG_WM
%Author: D.T.
%Date: 29 September 2020

clc;
clear all;
close all;

%% Set Path
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

epoch = 'cueLocked'; %cue-locked or response-locked analyses?

tfa_method = 'wavelet';

condition = {'load_1_correct', 'load_2_correct', 'load_4_correct'};
contrast = {'load1corr_VS_load2corr_VS_load4corr'};

blc = 0; %baseline correction or not?

%timeWin = {[-.25, -.1], [0, 0.5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.5], [4.5, 4.65]}; %cluster-based statistics will be computed seperately for each TOI
timeWin = {[-.25, -.1], [0, 0.5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.5]};
freqWin = {[8, 12], [13, 30], [30, 70], [70, 180], ...
    [70, 80], [80, 90], [90, 100], [100, 110], [110, 120], ...
    [130, 140], [140, 150], [150, 160], [160, 170], [170, 180]};
designType = 'within-subject_load';

freqWin_analysis = [70, 180]; % this is simply used since I sometimes run the same script in more than one place

%% Loop over subjects/conditions to extract/save condition-specific time-frequency estimates for each subject
for condi = 1 : length(condition)
    for subi = 1 : length(subnips)
        
        %Determine parameters
        params = ECoG_getParams(condition{condi});

        %Load initial TFA/behavioral data
        if strcmp(epoch, 'cueLocked')
            load([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_final.mat']);
            load([behavior_path  '/' subnips{subi} '_memory_behavior.mat']); %behavioral file
        else
            load([res_path subnips{subi} '/' subnips{subi} '_respLocked_tfa_wavelet.mat']);
            load([behavior_path  '/' subnips{subi} '_memory_behavior.mat']); %behavioral file
        end

        %Select data
        [allTrials, selTrials] = ECoG_selectTrials(params, data_mem(data_mem.EEG_included == 1, :));
        tmp = [1 : length(allTrials)];

        cfg = [];
        cfg.trials = tmp(selTrials);

        freq_cond = ft_selectdata(cfg, freq);

        %Save
        if strcmp(epoch, 'cueLocked')
            save([res_path subnips{subi} '/' subnips{subi} '_' condition{condi} '_tfa_wavelet_final.mat'], 'freq_cond', '-v7.3');
        else
            save([res_path subnips{subi} '/' subnips{subi} '_' condition{condi} '_' epoch '_tfa_wavelet_final.mat'], 'freq_cond', '-v7.3');
        end
        
        clear('freq', 'freq_cond');
    end
end

%% Loop over subjects/conditions to compare trial counts, subsample data (if need be), and perform cluster-based permutation test
for contrasti = 1 : length(contrast)
    for freqi = 1 : length(freqWin)
        for subi = 1 : length(subnips)
        
            if strcmp(contrast{contrasti}, 'task_match_correct_VS_task_mismatch_correct') || ...
                    strcmp(contrast{contrasti}, 'button_press_VS_no_button_press')
                
                if strcmp(epoch, 'cueLocked')
                    cond1 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{1} '_tfa_wavelet_final.mat']);
                    cond2 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{2} '_tfa_wavelet_final.mat']);
                else
                    cond1 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{1} '_' epoch '_tfa_wavelet_final.mat']);
                    cond2 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{2} '_' epoch '_tfa_wavelet_final.mat']);
                end
                    
                %Compare the trial numbers for the different conditions
                trials1 = size(cond1.freq_cond.powspctrm, 1);
                trials2 = size(cond2.freq_cond.powspctrm, 1);
                trials = [trials1, trials2];

                tmp_min = find(trials == min(trials));
                tmp_max = find(trials == max(trials));

                my_diff = trials(tmp_max) - trials(tmp_min);
                display(num2str(my_diff));
                %pause;
            elseif strcmp(contrast{contrasti}, 'load1corr_VS_load2corr_VS_load4corr')
                cond1 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{1} '_tfa_wavelet_final.mat']);
                cond2 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{2} '_tfa_wavelet_final.mat']);
                cond3 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{3} '_tfa_wavelet_final.mat']);
                
                %Compare the trial numbers for the different conditions
                trials1 = size(cond1.freq_cond.powspctrm, 1);
                trials2 = size(cond2.freq_cond.powspctrm, 1);
                trials3 = size(cond3.freq_cond.powspctrm, 1);
                trials = [trials1, trials2, trials3]; 

                tmp_min = find(trials == min(trials));
                tmp_max = find(trials == max(trials));

                my_diff = trials(tmp_max) - trials(tmp_min);
                display(num2str(my_diff));
            end

            %Within-subject cluster-based permutation test (to assess how
            %reliable group differences are, and whether certain electrodes
            %might be driving the effect
            
            for timei = 1 : length(timeWin)       
                display(['Computing cluster-based permutation for contrast: ' contrast{contrasti}, ', subject: ' subnips{subi}, ', frequency: ' num2str(freqWin{freqi}(1)), ', and time: ' num2str(timeWin{timei}(1))]);
                
                if strcmp(contrast{contrasti}, 'task_match_correct_VS_task_mismatch_correct')
                    stats{contrasti}{timei} = ECoG_computeClustStat(cond1, cond2, timeWin{timei}, freqWin{freqi}, designType, subi);
                else
                    stats{contrasti}{timei} = ECoG_computeClustStat(cond1, cond2, cond3, timeWin{timei}, freqWin{freqi}, designType, subi);
                end
            end

            %Save
            if strcmp(epoch, 'cueLocked')
                if strcmp(timeWin, 'all')
                    save(['/media/darinka/Data0/iEEG/Results/TFA/Stats/' subnips{subi} '_ClustStat_' contrast{contrasti} '_' timeWin '_' num2str(freqWin{freqi}(1)) '_to_' num2str(freqWin{freqi}(2)) 'Hz.mat'], 'stats');
                else
                    save(['/media/darinka/Data0/iEEG/Results/TFA/Stats/' subnips{subi} '_ClustStat_' contrast{contrasti} '_allTOIs_' num2str(freqWin{freqi}(1)) '_to_' num2str(freqWin{freqi}(2)) 'Hz.mat'], 'stats');
                end
            else
                save(['/media/darinka/Data0/iEEG/Results/TFA/Stats/' subnips{subi} '_ClustStat_' contrast{contrasti} '_' timeWin '_' epoch '_' num2str(freqWin{freqi}(1)) '_to_' num2str(freqWin{freqi}(2)) 'Hz.mat'], 'stats');
            end
        end
    end
end
