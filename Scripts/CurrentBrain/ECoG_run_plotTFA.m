%This is the main script to plot the TFA ECoG data.
%Project: ECoG_WM
%Author: D.T.
%Date: 24 September 2020

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

tfa_method = 'wavelet';
condition = {'task_match_correct', 'task_mismatch_correct'};
% condition = {'task_match', 'task_match_correct', 'task_mismatch', 'task_mismatch_correct', ...
%     'load_1', 'load_2', 'load_4', 'load_1_correct', 'load_2_correct', 'load_4_correct', ...
%     'probe_match', 'probe_match_correct', 'probe_mismatch', 'probe_mismatch_correct', ...
%     'task_match_probe_match_correct', 'task_match_probe_mismatch_correct', 'task_mismatch_probe_match_correct', 'task_mismatch_probe_mismatch_correct'};

%% Extract TFA, plot, and save
for condi = 1 : length(condition)
    
    if strcmp(condition{condi}, 'task_match')
        params.cue = 'match';
        params.load = 'all';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'all';
    elseif strcmp(condition{condi}, 'task_match_correct')
        params.cue = 'match';
        params.load = 'all';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'task_mismatch')
        params.cue = 'mismatch';
        params.load = 'all';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'all';
    elseif strcmp(condition{condi}, 'task_mismatch_correct')
        params.cue = 'mismatch';
        params.load = 'all';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'load_1')
        params.cue = 'all';
        params.load = 'load1';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'all';
    elseif strcmp(condition{condi}, 'load_2')
        params.cue = 'all';
        params.load = 'load2';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'all';
        params.resp = 'all';
    elseif strcmp(condition{condi}, 'load_4')
        params.cue = 'all';
        params.load = 'load4';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'all';
    elseif strcmp(condition{condi}, 'load_1_correct')
        params.cue = 'all';
        params.load = 'load1';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'load_2_correct')
        params.cue = 'all';
        params.load = 'load2';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'load_4_correct')
        params.cue = 'all';
        params.load = 'load4';
        params.probe = 'all';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'probe_match')
        params.cue = 'all';
        params.load = 'all';
        params.probe = 'match';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'all';
    elseif strcmp(condition{condi}, 'probe_match_correct')
        params.cue = 'all';
        params.load = 'all';
        params.probe = 'match';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'probe_mismatch')
        params.cue = 'all';
        params.load = 'all';
        params.probe = 'mismatch';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'all';
    elseif strcmp(condition{condi}, 'probe_mismatch_correct')
        params.cue = 'all';
        params.load = 'all';
        params.probe = 'mismatch';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'task_match_probe_match_correct')
        params.cue = 'match';
        params.load = 'all';
        params.probe = 'match';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'task_match_probe_mismatch_correct')
        params.cue = 'match';
        params.load = 'all';
        params.probe = 'mismatch';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'task_mismatch_probe_match_correct')
        params.cue = 'mismatch';
        params.load = 'all';
        params.probe = 'match';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    elseif strcmp(condition{condi}, 'task_mismatch_probe_mismatch_correct')
        params.cue = 'mismatch';
        params.load = 'all';
        params.probe = 'mismatch';
        params.id = 'all';
        params.probe_id = 'all';
        params.resp = 'correct';
    end
        
    for subi = 1 : length(subnips)
        averageFreq{subi} = ECoG_plotTFA(subnips{subi}, condition{condi}, params, res_path, behavior_path);
    end
    
    %Plot entire frequency spectrum (averaged across channels within
    %subject)
    for subi = 1 : length(subnips)
        averageFreq_channel{subi} = averageFreq{subi};
        averageFreq_channel{subi}.powspctrm = mean(averageFreq_channel{subi}.powspctrm, 1);
        averageFreq_channel{subi} = rmfield(averageFreq_channel{subi}, 'label');
        averageFreq_channel{subi}.label{1} = 'averageIEEG';
    end

    cfg = [];
    grandAverage = ft_freqgrandaverage(cfg, averageFreq_channel{:});

    %Plot
    cfg = [];
    cfg.baseline = [-.44, -.15];
    cfg.baselinetype = 'db';
    cfg.title = condition{condi};

    ft_singleplotTFR(cfg, grandAverage);

    hold on;
    plot([0, 0], [0, 240], '-k'); %cue
    plot([1.5, 1.5], [0, 240], '-k'); %memory items
    plot([4.5, 4.5], [0, 240], '-k'); %response

    %Save data and figure
    save(['/media/darinka/Data0/iEEG/Results/TFA/AverageTFA_' condition{condi} '_averageFreq.mat'], 'averageFreq');
    saveas(gcf, ['/media/darinka/Data0/iEEG/Results/TFA/Figures/AverageTFA_' condition{condi} '_averageFreq.tiff']);
    
    close(gcf);
end