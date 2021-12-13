%This is the main script to check each subjects electrodes to assess
%whether they are gray or white matter
%Project: ECoG_WM
%Author: D.T.
%Date: 17 Nov 2021

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips
foi = [70, 150];

%%  Load TFA decomposition and plot mean power spectrum/electrode
for subi = 1 : length(subnips)
    
    %load([res_path subnips{subi} '/' subnips{subi} '_highGammaPower_corrected_alex.mat']); %trials x channels x freqs x time
    load([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_final.mat']);
    
    %Extract frequencies of interest
    cfg = [];
    cfg.frequency = foi;
    
    freq = ft_selectdata(cfg, freq);
    
    %Apply baseline correction
    cfg = [];
    cfg.baseline = [-0.25, -0.05];
    cfg.baselinetype = 'db';
    
    freq = ft_freqbaseline(cfg, freq);
    
    %Plot
    figure;
    for subploti = 1 : size(freq.powspctrm, 2)
        subplot(5, 10, subploti);
        
        imagesc(squeeze(mean(freq.powspctrm(:, subploti, :, :))));
        set(gca,'YDir','normal');
        
        %Change x- and y-labels
        
    end
end
    