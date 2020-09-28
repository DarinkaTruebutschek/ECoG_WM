%This function computes the average time frequency spectrum as a function
%of condition
%Project: ECoG_WM
%Author: D.T.
%Date: 22 September 2020

function averageFreq = ECoG_plotTFA(subnips, condition, params, res_path, behavior_path)

%% Load data and select relevant subset

%Load initial data
load([res_path subnips '/' subnips '_tfa_wavelet_final.mat']);
load([behavior_path  '/' subnips '_memory_behavior.mat']); %behavioral file

%Sanity check
if size(freq.powspctrm, 1) ~= sum(data_mem.EEG_included == 1)
 display('ERROR! Trial numbers do not match.');
end

%Select data
[allTrials, selTrials] = ECoG_selectTrials(params, data_mem(data_mem.EEG_included == 1, :));
tmp = [1 : length(allTrials)];

cfg = [];
cfg.trials = tmp(selTrials);

selData = ft_selectdata(cfg, freq);

%Average
cfg = [];
averageFreq = ft_freqdescriptives(cfg, selData);
averageFreq.elec = selData.elec;
averageFreq.elec_mni_frv = selData.elec_mni_frv;

%% Plot each subject individually, to get an overview of the channels

cfg = [];
cfg.baseline = [-.44, -.15];
cfg.baselinetype  = 'db';
cfg.layout = averageFreq.elec;
cfg.title = condition;

ft_multiplotTFR(cfg, averageFreq);

savefig(gcf, ['/media/darinka/Data0/iEEG/Results/TFA/Figures/TFA_' subnips '_' condition '_multiplot.fig']);

close(gcf);
end
  

