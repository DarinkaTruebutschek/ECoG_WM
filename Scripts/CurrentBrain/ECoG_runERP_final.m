%This script runs the final ERP analysis.
%Project: ECoG_WM
%Author: D.T.
%Date: 06 October 2020

clear all;
clc;
close all;

%% Path
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

erp_method = 'erp_100'; %lowpass-filtered at 30Hz & downsampled to 100 Hz
condition = {'task_match_correct', 'task_mismatch_correct'};
contrast = {'task_match_correct_VS_task_mismatch_correct'};

epoch = 'cueLocked'; %cue-locked or response-locked analyses?
timeWin = {[-.25, 0], [0, 0.5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.5]};
blc = 1; %baseline correction or not?

my_colors = cbrewer('div', 'Spectral', 10);

%% First, save relevant condition files
for subi = 1 : length(subnips)
    
    %Load data
    load([behavior_path  '/' subnips{subi} '_memory_behavior_combined.mat']); %behavioral file
    if strcmp(epoch, 'cueLocked')
        load([res_path subnips{subi} '/' subnips{subi} '_erp_100.mat']);
    else
        load([res_path subnips{subi} '/' subnips{subi} '_respLocked_erp_100.mat']);
    end
    
    %Apply baseline correction if wanted
    if blc
        cfg = [];
        cfg.baselinewindow = timeWin{1};
        cfg.demean = 'yes';
        
        dat_blc = ft_preprocessing(cfg, data);
        data = dat_blc;
        
        clear('dat_blc');
    end
    
    %Extract relevant conditions and average
    for condi = 1 : length(condition)
        
        %Get parameters
        params = ECoG_getParams(condition{condi});
        
        %Select data
        [allTrials, selTrials] = ECoG_selectTrials(params, data_mem(data_mem.EEG_included == 1, :));
        tmp = [1 : length(allTrials)];

        cfg = [];
        cfg.trials = tmp(selTrials);
        
        erp_cond = ft_selectdata(cfg, data);
        
        %Save
        if strcmp(epoch, 'cueLocked')
            save([res_path subnips{subi} '/' subnips{subi} '_' condition{condi} '_erp_100_final.mat'], 'erp_cond', '-v7.3');
        else
            save([res_path subnips{subi} '/' subnips{subi} '_' condition{condi} '_' epoch 'respLocked_erp_100_final.mat'], 'erp_cond', '-v7.3');
        end
        
        clear('allTrials', 'selTrials', 'erp_cond');
    end
end

%% Plot within-subject average ERPs (across all sensors) to get an idea of potential condition differences
for subi = 1 : length(subnips)
    for contrasti = 1 : length(contrast)
        
        %Load data & average
        if strcmp(contrast{contrasti}, 'task_match_correct_VS_task_mismatch_correct') 
            if strcmp(epoch, 'cueLocked')
                cond1 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{1} '_erp_100_final.mat']);
                cond2 = load([res_path subnips{subi} '/' subnips{subi} '_' condition{2} '_erp_100_final.mat']);
                
                cfg = [];
                cond1_avg = ft_timelockanalysis(cfg, cond1.erp_cond);
                cond2_avg = ft_timelockanalysis(cfg, cond2.erp_cond);
            end
        end
        
        %Plot multiplot for visual inspection
        cfg = [];
        cfg.parameter = 'avg';
        cfg.layout = cond1.erp_cond.elec;
        
        figure;
        ft_multiplotER(cfg, cond1_avg, cond2_avg);
        
        %pause;
        
        %Plot average across all channels
        figure;
        hold on;
        plot(cond1.erp_cond.time{1}, cond1_avg.avg(1:22, :));
        plot(cond1.erp_cond.time{1}, mean(cond1_avg.avg(1:22, :)), 'Color', 'k', 'LineWidth', 2);
        plot(cond1.erp_cond.time{1}, cond1_avg.avg(23:44, :));
        plot(cond1.erp_cond.time{1}, mean(cond1_avg.avg(23:44, :)), 'Color', 'k', 'LineWidth', 2);
        
        %hold on
        %plot(cond1.erp_cond.time{1}, mean(cond1_avg.avg), 'LineWidth', 1.5, 'Color', my_colors(1, :));
        %plot(cond1.erp_cond.time{1}, mean(cond2_avg.avg), 'LineWidth', 1.5, 'Color', my_colors(2, :));
        %plot(cond1.erp_cond.time{1}, mean_avg1, 'LineWidth', 1.5, 'Color', my_colors(3, :));
        %plot(cond1.erp_cond.time{1}, mean_avg2, 'LineWidth', 1.5, 'Color', my_colors(4, :));
        %plot(cond1.erp_cond.time{1}, cond1_avg.avg(1, :), 'LineWidth', 1.5, 'Color', my_colors(5, :));
        %plot(cond1.erp_cond.time{1}, cond1_avg.avg(44, :), 'LineWidth', 1.5, 'Color', my_colors(6, :));
        
        %Legend
        legend;
        
        %Event markers
        hold on;
        plot([0, 0], [-10, 10], '-k'); %cue
        plot([1.5, 1.5], [-10, 10], '-k'); %memory items
        plot([4.5, 4.5], [-10, 10], '-k'); %response
        
        xlim([-.25, 4.5]);
        ylim([min(min([mean(cond1_avg.avg); mean(cond2_avg.avg); mean_avg1])), max(max([mean(cond1_avg.avg); mean(cond2_avg.avg); mean_avg1]))]);
        
        %Save
        printfig(gcf, [0 0 15 10], ['/media/darinka/Data0/iEEG/Results/ERF/Figures/' subnips{subi} '_' contrast{contrasti} '_erp_100.tiff']);
        close(gcf);  
    end
end
