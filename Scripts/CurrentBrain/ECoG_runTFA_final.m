%This script runs the final TFA analysis.
%Project: ECoG_WM
%Author: D.T.
%Date: 25 September 2020

clc;
clear all;
close all;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

tfa_method = 'wavelet';
condition = {'task_match_correct', 'task_mismatch_correct'};
contrast = {'task_match_correct_VS_task_mismatch_correct'};

timeWin = 'all';
freqWin = {[8, 12], [13, 30], [30, 70], [70, 180], ...
    [70, 80], [80, 90], [90, 100], [100, 110], [110, 120], ...
    [130, 140], [140, 150], [150, 160], [160, 170], [170, 180]};
freqWin_analysis = [70, 180]; % this is simply used since I sometimes run the same script in more than one place

%% Loop over subjects/conditions to 1) extract/save condition-specific time-frequency estimates for each subject
for condi = 1 : length(condition)
    for subi = 1 : length(subnips)
        
        %Determine parameters
        params = ECoG_getParams(condition{condi});

        %Load initial TFA/behavioral data
        load([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_final.mat']);
        load([behavior_path  '/' subnips{subi} '_memory_behavior.mat']); %behavioral file

        %Select data
        [allTrials, selTrials] = ECoG_selectTrials(params, data_mem(data_mem.EEG_included == 1, :));
        tmp = [1 : length(allTrials)];

        cfg = [];
        cfg.trials = tmp(selTrials);

        freq_cond = ft_selectdata(cfg, freq);

        %Save
        save([res_path subnips{subi} '/' subnips{subi} '_' condition{condi} '_Hz_tfa_wavelet_final.mat'], 'freq_cond', '-v7.3');

        clear('freq', 'freq_cond');
    end
end

%% Loop over subjects/conditions to compare trial counts, subsample data (if need be), and perform cluster-based permutation test
for contrasti = 1 : length(contrast)
    for freqi = 1 : length(freqWin)
        for subi = 1 : length(subnips)
        
            if strcmp(contrast{contrasti}, 'task_match_correct_VS_task_mismatch_correct')
                cond1 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{1} '_tfa_wavelet_final.mat']);
                cond2 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{2} '_tfa_wavelet_final.mat']);

                %Compare the trial numbers for the different conditions
                trials1 = size(cond1.freq_cond.powspctrm, 1);
                trials2 = size(cond2.freq_cond.powspctrm, 1);
                trials = [trials1, trials2];

                tmp_min = find(trials == min(trials));
                tmp_max = find(trials == max(trials));

                my_diff = trials(tmp_max) - trials(tmp_min);
                display(num2str(my_diff));
                %pause;

                if my_diff/trials(tmp_max) > .15

                    %Subsample/bootstrap
                end
            end

            %Within-subject cluster-based permutation test (to assess how
            %reliable group differences are, and whether certain electrodes
            %might be driving the effect
            designType = 'within-subject';
            stats{contrasti} = ECoG_computeClustStat(cond1, cond2, timeWin, freqWin{freqi}, designType, subi);

            %Save
            save(['/media/darinka/Data0/iEEG/Results/TFA/Stats/' subnips{subi} '_ClustStat_' contrast{contrasti} '_' timeWin '_' num2str(freqWin{freqi}(1)) '_to_' num2str(freqWin{freqi}(2)) 'Hz.mat'], 'stats');
        end
    end
end
                    
%% Loop over subjects/conditions to identify significant frequencies/channels
for contrasti = 1 : length(contrast)
    for subi = 1 : length(subnips)
        if strcmp(contrast{contrasti}, 'task_match_correct_VS_task_mismatch_correct')
            load(['/media/darinka/Data0/iEEG/Results/TFA/Stats/' subnips{subi} '_ClustStat_' contrast{contrasti} '_' timeWin '_' num2str(freqWin_analysis(1)) '_to_' num2str(freqWin_analysis(2)) 'Hz.mat']);
            cond1 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{1} '_tfa_wavelet_final.mat']);
            cond2 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{2} '_tfa_wavelet_final.mat']);
            
            if strcmp(freqWin, 'all')
                %Check which, if any, channels have a significant cluster
                counter = 1;
                for chani = 1 : length(cond1.freq_cond.label)
                    num_Clus(chani) = sum(sum((stats{contrasti}.prob(chani, :, :) <= stats{contrasti}.cfg.alpha)));
                    if num_Clus(chani) == 0
                        display(['There are no significant clusters in channel ' cond1.freq_cond.label{chani}]);
                        continue;
                    else
                        anatomicalLabel = ECoG_getAnatomicalChannel({cond1.freq_cond.label{chani}}, subnips{subi}, 'AFNI');
                    
                        subplot(8, 5, counter)
                        imagesc(cond1.freq_cond.time, cond1.freq_cond.freq, squeeze(stats{contrasti}.prob(chani, :, :) <= stats{contrasti}.cfg.alpha));
                        set(gca, 'YDir', 'normal');
                        title([cond1.freq_cond.label{chani} '/' anatomicalLabel{1}{1}]);
                        counter = counter + 1;
                    
                        %Event markers
                        hold on;
                        plot([0, 0], [0, 240], '-k'); %cue
                        plot([1.5, 1.5], [0, 240], '-k'); %memory items
                        plot([4.5, 4.5], [0, 240], '-k'); %response
                    end
                end
                
                %Save
                printfig(gcf, [0, 0, 60, 40], ['/media/darinka/Data0/iEEG/Results/TFA/Figures/' subnips{subi} '_SigClusters_' contrast{contrasti} '_' timeWin '.tiff']);
                close(gcf);
            else 
                %Compute average for respective conditions
                cfg = [];
                cfg.frequency = [freqWin_analysis(1), freqWin_analysis(2)];
                cond1 = ft_freqdescriptives(cfg, cond1.freq_cond);
                cond2 = ft_freqdescriptives(cfg, cond2.freq_cond);
                
                %Baseline correction
                cfg = [];
                cfg.baseline = [-.25, -.1];
                cfg.baselinetype = 'db';
                
                cond1 = ft_freqbaseline(cfg, cond1);
                cond2 = ft_freqbaseline(cfg, cond2);
                
                %Subtract
                cfg = [];
                cfg.parameter = 'powspctrm';
                cfg.operation = 'subtract';
                
                raweffect = ft_math(cfg, cond1, cond2);
                
                %Plot
                figure;
                t1 = nearest(cond1.time, -.25);
                t2 = nearest(cond1.time, 4.2);
                
                clim = [-3, 3];
                mask = squeeze(stats{contrasti}.prob <= stats{contrasti}.cfg.alpha);
                dat = squeeze(mean(raweffect.powspctrm, 2)).* mask; %if mask == 0, dat entry will also be 0
                
                imagesc(cond1.time(t1 : t2), [1 : length(cond1.label)], dat(:, t1 : t2));
                set(gca, 'YDir', 'normal');
                          
                %Event markers
                hold on;
                plot([0, 0], [0, 240], '-k'); %cue
                plot([1.5, 1.5], [0, 240], '-k'); %memory items
                plot([4.5, 4.5], [0, 240], '-k'); %response
                
                %Ylabel
                set(gca, 'ytick', [1 : 1 : length(cond1.label)], 'yticklabel', cond1.label');
                
                %Save
                printfig(gcf, [0, 0, 18, 12], ['/media/darinka/Data0/iEEG/Results/TFA/Figures/' subnips{subi} '_SigClusters_' contrast{contrasti} '_' timeWin '_' num2str(freqWin_analysis(1)) '_to_' num2str(freqWin_analysis(2)) 'Hz.tiff']);
                close(gcf);
            end
        end
    end
end


 
                
                
                
                
                
                
                
                
                
                
                
                
         
