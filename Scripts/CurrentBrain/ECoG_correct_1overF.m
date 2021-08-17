%This is the main script to extract high gamma power (as a correlate of
%neural spiking) from the ECoG data
%Project: ECoG_WM
%Author: D.T.
%Date: 18 May 2021

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

extract_method = 'alex'; %or: alex
epoch = 'cueLocked';

%% Specify important parameters
minf = 70;
maxf = 150;
nfreqs = 10;

if strcmp(extract_method, 'fieldtrip')
    tfa_method = 'tfr'; %wavelets
    
    if strcmp(epoch, 'cueLocked')
        tfa_toi = [-0.14 : 0.04 : 4.3];
    elseif strcmp(epoch, 'respLocked')
        tfa_toi= [-0.14 : 0.04 : 4.3];
    end
    
    tfa_foi = logspace(log10(minf), log10(maxf), nfreqs);
    tfa_foi = unique(round(tfa_foi));
    
    tfa_width = 10 * ones(1, length(tfa_foi));
elseif strcmp(extract_method, 'alex')
    tfa_method = 'hilbert';
    
    if strcmp(epoch, 'cueLocked')
        tfa_toi = [-0.14 : 0.04 : 4.3];
    elseif strcmp(epoch, 'respLocked')
        tfa_toi= [-0.14 : 0.04 : 4.3];
    end
    
    tfa_foi = [minf : nfreqs : maxf-nfreqs];
end

%% Loop over subjects to extract HFP and save the resultant data file
for subi = 1 : length(subnips)
    
    %Load initial data
    load([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_final.mat']);
    
    %Select only relevant data
    cfg = [];
    cfg.latency = [tfa_toi(1), tfa_toi(end)];
    cfg.frequency = [tfa_foi(1), tfa_foi(end)];
        
    freq = ft_selectdata(cfg, freq);
    
    %Plot spectrum to get an idea
    figure;
    plot(squeeze(mean(mean(mean(freq.powspctrm, 4)))));
    
    %Normalize data (to account for 1/f dropoff): To be discussed,
    %normalize each trial individually or considering the entire
    %data (currently done)
    freq_norm = freq;
    
    for freqi = 1 : size(freq_norm.powspctrm, 3)
        meanBand(freqi, :) = squeeze(nanmean(nanmean(freq.powspctrm(:, :, freqi, :), 1), 4));
    end
    
    for freqi = 1 : size(freq_norm.powspctrm, 3)
        for chani = 1 : size(freq_norm.powspctrm, 2)
            freq_norm.powspctrm(:, chani, freqi, :) = freq_norm.powspctrm(:, chani, freqi, :) ./ meanBand(freqi, chani);
        end
    end
        
    %Plot to check results
    figure;
    plot(squeeze(mean(mean(mean(freq_norm.powspctrm, 4)))));
    
    freq = freq_norm;
    
    %Save
    save([res_path subnips{subi} '/' subnips{subi} '_highGammaPower_corrected_' extract_method '.mat'], 'freq', '-v7.3');
 
    clear('meanBand', 'freq', 'freq_norm');
end







