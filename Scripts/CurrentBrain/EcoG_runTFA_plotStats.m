%This script plots the results of the cluster-based permutation test.
%Project: ECoG_WM
%Author: D.T.
%Date: 01 October 2020

clc;
clear all;
close all;

%% Set Path
ECoG_setPath;
%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

epoch = 'cueLocked'; %cue-locked or response-locked analyses?

tfa_method = 'wavelet';

condition = {'task_match_correct', 'task_mismatch_correct'};
contrast = {'task_match_correct_VS_task_mismatch_correct'};

blc = 0; %baseline correction or not?

%timeWin = {[-.25, -.1], [0, 0.5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.5], [4.5, 4.65]}; %cluster-based statistics will be computed seperately for each TOI
timeWin = {[-.25, -.1], [0, 0.5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.5]};
freqWin = {[8, 12], [13, 30], [30, 70], [70, 180], ...
    [70, 80], [80, 90], [90, 100], [100, 110], [110, 120], ...
    [130, 140], [140, 150], [150, 160], [160, 170], [170, 180]};
designType = 'within-subject';

%% Initialize needed variables

%% First, check whether there are any significant timepoints
for contrasti = 1 : length(contrast)
    for freqi = 1 : length(freqWin)
        for subi = 1 : length(subnips)
            
            %Load the stats file
            if strcmp(contrast{contrasti}, 'task_match_correct_VS_task_mismatch_correct') || ...
                    strcmp(contrast{contrasti}, 'button_press_VS_no_button_press')
                if strcmp(epoch, 'cueLocked')
                    if ~strcmp(timeWin, 'all')
                        load(['/media/darinka/Data0/iEEG/Results/TFA/Stats/' subnips{subi} '_ClustStat_' contrast{contrasti} '_allTOIs_' num2str(freqWin{freqi}(1)) '_to_' num2str(freqWin{freqi}(2)) 'Hz.mat']);
                    end
                end
            end
            
            %Loop over the individual TOIs & determine whether there are
            %any significant condition differences
            for timei = 1 : length(timeWin)
                
                %Get time indices
                time{contrasti}{timei} = stats{contrasti}{timei}.time;
                
                %Positive clusters?
                if isfield(stats{contrasti}{timei}, 'posclusters')
                    if isempty(stats{contrasti}{timei}.posclusters)
                        pos{contrasti}{timei} = zeros(size(stats{contrasti}{timei}.prob, 1), size(stats{contrasti}{timei}.stat, 3));
                    else
                        pos_cluster_pvals{contrasti}{timei} = [stats{contrasti}{timei}.posclusters(:).prob];
                        pos_signif_clust{contrasti}{timei} = find(pos_cluster_pvals{contrasti}{timei} < stats{contrasti}{timei}.cfg.alpha);
                        pos{contrasti}{timei} = ismember(stats{contrasti}{timei}.posclusterslabelmat, pos_signif_clust{contrasti}{timei});
                        pos{contrasti}{timei} = squeeze(pos{contrasti}{timei});
                    end
                else
                    pos{contrasti}{timei} = zeros(size(stats{contrasti}{timei}.prob, 1), size(stats{contrasti}{timei}.stat, 3));
                end
                
                %Negative clusters?
                if isfield(stats{contrasti}{timei}, 'negclusters')
                    if isempty(stats{contrasti}{timei}.negclusters)
                        neg{contrasti}{timei} = zeros(size(stats{contrasti}{timei}.prob, 1), size(stats{contrasti}{timei}.stat, 3));
                    else
                        neg_cluster_pvals{contrasti}{timei} = [stats{contrasti}{timei}.negclusters(:).prob];
                        neg_signif_clust{contrasti}{timei} = find(neg_cluster_pvals{contrasti}{timei} < stats{contrasti}{timei}.cfg.alpha);
                        neg{contrasti}{timei} = ismember(stats{contrasti}{timei}.negclusterslabelmat, neg_signif_clust{contrasti}{timei});
                        neg{contrasti}{timei} = squeeze(neg{contrasti}{timei});
                    end
                else
                    neg{contrasti}{timei} = zeros(size(stats{contrasti}{timei}.prob, 1), size(stats{contrasti}{timei}.stat, 3));
                end
            end
            
            pos{contrasti} = cat(2, pos{contrasti}{:});
            neg{contrasti} = cat(2, neg{contrasti}{:});
            time{contrasti} = cat(2, time{contrasti}{:});
            
            %Quick & dirty plot
            figure;
            
            subplot(2, 1, 1);
            imagesc(time{contrasti}, [1 : length(stats{1}{1}.label)], pos{contrasti});
            set(gca, 'YDir', 'normal');
            title(['Positive clusters: ' contrast{contrasti} ', ' subnips{subi} ', ' num2str(freqWin{freqi}(1)) ' to ' num2str(freqWin{freqi}(2))]);
                                
            %Event markers
            hold on;
            plot([0, 0], [0, 240], '-k'); %cue
            plot([1.5, 1.5], [0, 240], '-k'); %memory items
            plot([4.5, 4.5], [0, 240], '-k'); %response
                         
            %ylabel
            set(gca, 'ytick', [1 : 1 : length(stats{1}{1}.label)], 'yticklabel', stats{1}{1}.label');

            subplot(2, 1, 2);
            imagesc(time{contrasti}, [1 : length(stats{1}{1}.label)], neg{contrasti});
            set(gca, 'YDir', 'normal');
            title('Negative clusters');
            
            %Event markers
            hold on;
            plot([0, 0], [0, 240], '-k'); %cue
            plot([1.5, 1.5], [0, 240], '-k'); %memory items
            plot([4.5, 4.5], [0, 240], '-k'); %response
            
            %ylabel
            set(gca, 'ytick', [1 : 1 : length(stats{1}{1}.label)], 'yticklabel', stats{1}{1}.label');
            
            %Save
            printfig(gcf, [0, 0, 18, 30], ['/media/darinka/Data0/iEEG/Results/TFA/Figures/' subnips{subi} '_SigClusters_' contrast{contrasti} '_allTOIs_' num2str(freqWin{freqi}(1)) '_to_' num2str(freqWin{freqi}(2)) 'Hz.tiff']);
            close(gcf);
            
            clear('pos', 'neg', 'time');
        end
    end
end
 

%% Loop over subjects/conditions to identify significant frequencies/channels
for contrasti = 1 : length(contrast)
    for subi = 1 : length(subnips)
        if strcmp(contrast{contrasti}, 'task_match_correct_VS_task_mismatch_correct') || ...
                    strcmp(contrast{contrasti}, 'button_press_VS_no_button_press')
            if strcmp(epoch, 'cueLocked')
                load(['/media/darinka/Data0/iEEG/Results/TFA/Stats/' subnips{subi} '_ClustStat_' contrast{contrasti} '_' timeWin '_' num2str(freqWin_analysis(1)) '_to_' num2str(freqWin_analysis(2)) 'Hz.mat']);
                cond1 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{1} '_tfa_wavelet_final.mat']);
                cond2 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{2} '_tfa_wavelet_final.mat']);
            else
                load(['/media/darinka/Data0/iEEG/Results/TFA/Stats/' subnips{subi} '_ClustStat_' contrast{contrasti} '_' timeWin '_' epoch '_' num2str(freqWin_analysis(1)) '_to_' num2str(freqWin_analysis(2)) 'Hz.mat']);
                cond1 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{1} '_' epoch '_tfa_wavelet_final.mat']);
                cond2 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{2} '_' epoch '_tfa_wavelet_final.mat']);
            end
            
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
                if strcmp(epoch, 'cueLocked')
                    cfg = [];
                    cfg.baseline = [-.25, -.1];
                    cfg.baselinetype = 'db';
                
                    cond1 = ft_freqbaseline(cfg, cond1);
                    cond2 = ft_freqbaseline(cfg, cond2);
                else
                    cfg = [];
                    cfg.baseline = [-3.5, -3.35]; %this is just randomly taken at some point in the time-period leading up to the response
                    cfg.baselinetype = 'db';
                
                    cond1 = ft_freqbaseline(cfg, cond1);
                    cond2 = ft_freqbaseline(cfg, cond2); 
                end
                
                %Subtract
                cfg = [];
                cfg.parameter = 'powspctrm';
                cfg.operation = 'subtract';
                
                raweffect = ft_math(cfg, cond1, cond2);
                
                %Plot
                figure;
                
                if strcmp(epoch, 'cueLocked')
                    t1 = nearest(cond1.time, -.25);
                    t2 = nearest(cond1.time, 4.2);
                else
                    t1 = nearest(cond1.time, -3.35);
                    t2 = length(cond1.time);
                end
                
                clim = [-3, 3];
                mask = squeeze(stats{contrasti}.prob <= stats{contrasti}.cfg.alpha);
                dat = squeeze(mean(raweffect.powspctrm, 2)).* mask; %if mask == 0, dat entry will also be 0

                imagesc(cond1.time(t1 : t2), [1 : length(cond1.label)], dat(:, t1 : t2));  
                set(gca, 'YDir', 'normal');
                          
                %Event markers
                hold on;
                
                if strcmp(epoch, 'cueLocked')
                    plot([0, 0], [0, 240], '-k'); %cue
                    plot([1.5, 1.5], [0, 240], '-k'); %memory items
                    plot([4.5, 4.5], [0, 240], '-k'); %response
                else
                    plot([0, 0], [0, 240], '-k'); %response
                end
                    
                %Ylabel
                set(gca, 'ytick', [1 : 1 : length(cond1.label)], 'yticklabel', cond1.label');
                
                %Save
                if strcmp(epoch, 'cueLocked')
                    printfig(gcf, [0, 0, 18, 12], ['/media/darinka/Data0/iEEG/Results/TFA/Figures/' subnips{subi} '_SigClusters_' contrast{contrasti} '_' timeWin '_' num2str(freqWin_analysis(1)) '_to_' num2str(freqWin_analysis(2)) 'Hz.tiff']);
                    close(gcf);
                else
                    printfig(gcf, [0, 0, 18, 12], ['/media/darinka/Data0/iEEG/Results/TFA/Figures/' subnips{subi} '_SigClusters_' contrast{contrasti} '_' timeWin '_' epoch '_' num2str(freqWin_analysis(1)) '_to_' num2str(freqWin_analysis(2)) 'Hz.tiff']);
                    close(gcf);
                end
            end
        end
    end
end


