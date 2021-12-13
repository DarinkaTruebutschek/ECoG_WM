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
epoch = 'respLocked';

%% Specify important parameters
minf = 70;
maxf = 150;
nfreqs = 10;

if strcmp(extract_method, 'fieldtrip')
    tfa_method = 'tfr'; %wavelets
    
    if strcmp(epoch, 'cueLocked')
        tfa_toi = [-0.44 : 0.01 : 4.650];
    elseif strcmp(epoch, 'respLocked')
        tfa_toi= [-0.44 : 0.01 : 4.650];
    end
    
    tfa_foi = logspace(log10(minf), log10(maxf), nfreqs);
    tfa_foi = unique(round(tfa_foi));
    
    tfa_width = 10 * ones(1, length(tfa_foi));
elseif strcmp(extract_method, 'alex')
    tfa_method = 'hilbert';
    
    if strcmp(epoch, 'cueLocked')
        tfa_toi = [-0.45 : 0.04 : 4.650];
    elseif strcmp(epoch, 'probeLocked_longEpoch')
        tfa_toi= [-4.5 : 0.04 : 0.5];
    elseif strcmp(epoch, 'respLocked')
        tfa_toi = [-4.0 : 0.04 : 0];
    end
    
    tfa_foi = [minf : nfreqs : maxf-nfreqs];
end

%% Loop over subjects to extract HFP and save the resultant data file
for subi = 1 : length(subnips)
    
    %Preprocess and select relevant data
    if strcmp(epoch, 'cueLocked')
        %Load initial data
        load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']);
    elseif strcmp(epoch, 'probeLocked_longEpoch')
        %Load initial data
        load([res_path subnips{subi} '/' subnips{subi} '_reref_probeLocked_longEpoch.mat']);
        reref = data_probeLocked;
    elseif strcmp(epoch, 'respLocked')
        %Load initial data
        load([res_path subnips{subi} '/' subnips{subi} '_reref_respLocked.mat']);
        reref = data_respLocked;
    end
    
    if strcmp(epoch, 'cueLocked')
        %Check sampling frequency to make sure 
        if reref.fsample ~= 1000
            disp('ATTENTION! Sample frequency deviates from 1000.');
        end
        
        %Check whether timing axis begins at the exact same time or not
        for triali = 1 : length(reref.time)
            begin_t(triali) = reref.time{triali}(1);
        end
        
        if numel(unique(begin_t)) > 1
            display('ATTENTION! Adjusting time axis to facilitate following analyses');
            
            my_difference = begin_t - (-.45); 
            
            %Adjust be measured differences
            for triali = 1 : length(reref.time)
                tmp{triali} = reref.time{triali} - my_difference(triali);
            end
            
            %Re-check
            for triali = 1 : length(reref.time)
                begin_t2(triali) = tmp{triali}(1);
            end
            
            display(num2str(unique(begin_t2(triali))));

            reref.time = tmp;
                
            clear('tmp');
        end
    end
       
       %Select data to only include the time window of interest to begin
       %with
        cfg = [];
        cfg.latency = [tfa_toi(1), tfa_toi(end)];
        
        tmp = ft_selectdata(cfg, reref);
        
        %Preprocess
        cfg = [];
        cfg.demean = 'yes';
        cfg.detrend = 'yes';
        
        tmp = ft_preprocessing(cfg, tmp);
    
    %Extract HFP
    if strcmp(extract_method, 'fieldtrip')
        
        %First, extract the relevant frequencies from the spectrum,
        %performing wavelet analysis
        cfg = [];
        cfg.method = tfa_method;
        cfg.keeptrials = 'yes';
        cfg.toi = tmp.time{1}; %keep full temporal resolution
        cfg.foi = tfa_foi;
        cfg.width = tfa_width;
        
        TFR = ft_freqanalysis(cfg, tmp);
        clear tmp
        
        %Initialize HGP as empty structure with the same dimensions as ERP
        cfg = [];
        cfg.latency = [tfa_toi(1), tfa_toi(end)];
        reref_avg = ft_timelockanalysis(cfg, reref);

        HGP = rmfield(reref_avg, {'avg', 'var'});
        
        %Correct for the 1/f dropoff
        freqCorr = reshape(TFR.freq .^2, [1, 1, length(TFR.freq)]);
        
        %Use repmat to create a matrix the same size as the TFR data
        freq = repmat(freqCorr, [size(TFR.powspctrm, 1), size(TFR.powspctrm, 2), 1, length(TFR.time)]);
        
        %Multiply data with freqCorr matrix and average over frequencies
        HGP.trial = squeeze(nanmean(TFR.powspctrm(:, :, :, :) .* freq, 3));
        
        %Calculate mean and variance
        HGP.avg = squeeze(nanmean(HGP.trial, 1));
        HGP.var = squeeze(nanvar(HGP.trial, 1));
        
        %Baseline correction
        %HGP.dimord = 'rpt_chan_time';
        
        %cfg = [];
        %cfg.baseline = [-.2, 0];
        
        %HGP_bl = ft_timelockbaseline(cfg, HGP);
        
        clear TFR*
    elseif strcmp(extract_method, 'alex')
        for freqi = 1 : length(tfa_foi)
            
            display(['Extracting frequency ' num2str(tfa_foi(freqi))]);
            
            %Bandpass filter signal & apply the Hilbert transform
            cfg = [];
            cfg.bpfilter = 'yes';
            cfg.bpfreq = [tfa_foi(freqi), tfa_foi(freqi)+nfreqs];
            cfg.bpfilttype = 'firws'; 
            %cfg.plotfiltresp = 'yes';
            cfg.keeptrials = 'yes';
            cfg.hilbert = 'abs';
            
            data_filt{freqi} = ft_preprocessing(cfg, tmp);
            
            %Restrict data to period of interest
            cfg = [];
            if strcmp(epoch, 'cueLocked')
                cfg.latency = [-.2, 4.5];
            elseif strcmp(epoch, 'probeLocked_longEpoch')
                cfg.lateny = [-4.5, 0.5];
            end
            
            data_filt{freqi} = ft_selectdata(cfg, data_filt{freqi});

            %Normalize data (to account for 1/f dropoff): To be discussed,
            %normalize each trial individually or considering the entire
            %data (currently done)
            
            data_filt_norm = data_filt;
%             meanBand = nanmean([data_filt{freqi}.trial{:}], 2);
%             
%             for triali = 1 : length(data_filt_norm{freqi}.trial)
%                 data_filt_norm{freqi}.trial{triali} = data_filt{freqi}.trial{triali} ./ meanBand;
%             end
        end
        
        %Load freq data
        load([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_final.mat']);
        
        %Fit filtered data into typical TF structure
        clear ('tmp')
        for freqi = 1 : length(tfa_foi)
            tmp{freqi} = zeros(length(data_filt_norm{freqi}.trial), size(data_filt_norm{freqi}.trial{1}, 1), size(data_filt_norm{freqi}.trial{1}, 2));
            
            for triali = 1 : length(data_filt_norm{freqi}.trial)
                tmp{freqi}(triali, :, :) = data_filt_norm{freqi}.trial{triali};
            end
        end
        
        powspctrm = zeros(length(tfa_foi), size(tmp{1}, 1), size(tmp{1}, 2), size(tmp{1}, 3));
        for freqi = 1 : length(tfa_foi)
            powspctrm(freqi, :, :, :) = tmp{freqi};
        end
        
        powspctrm = permute(powspctrm, [2, 3, 1, 4]);
        
        %Fill old freq struct
        freq.powspctrm = powspctrm;
        freq.freq = tfa_foi;
        freq.time = data_filt_norm{freqi}.time{1};
        
        %Plot spectrum to get an idea
        figure;
        plot(squeeze(mean(mean(mean(freq.powspctrm, 4)))));
        
        %Normalize
        freq_norm = freq;
    
        for freqi = 1 : size(freq_norm.powspctrm, 3)
            meanBand(freqi, :) = squeeze(nanmean(nanmean(freq.powspctrm(:, :, freqi, :), 1), 4));
        end
    
        for freqi = 1 : size(freq_norm.powspctrm, 3)
            for chani = 1 : size(freq_norm.powspctrm, 2)
                freq_norm.powspctrm(:, chani, freqi, :) = freq_norm.powspctrm(:, chani, freqi, :) ./ meanBand(freqi, chani);
            end
        end
        
        freq = freq_norm;
        
        %Plot spectrum to get an idea
        figure;
        plot(squeeze(mean(mean(mean(freq.powspctrm, 4)))));
    
        %Save
        save([res_path subnips{subi} '/' subnips{subi} '_highGammaPower_corrected_' extract_method '_respLocked.mat'], 'freq', '-v7.3');

        %Average over frequencies (to downsample)
        HGP = reref;
        
        powspctrm = squeeze(mean(freq.powspctrm, 3));
        
        for triali = 1 : length(HGP.trial)
            HGP.trial{triali} = squeeze(powspctrm(triali, :, :));
            HGP.time{triali} = freq.time;
        end
        
        %Downssample        
        cfg = [];
        cfg.resamplefs = 100;
        
        data = ft_resampledata(cfg, HGP); 
        
        %Remove table
        data = rmfield(data, 'trialInfo_all');
        
        %Save
        save([res_path subnips{subi} '/' subnips{subi} '_respLocked_HGP_100.mat'], 'data', '-v7.3');   
        clear('data', 'HGP', 'tmp', 'meanBand', 'freq', 'freq_norm');
    end
end
   
    
    
        
%         %HGP = rmfield(reref_avg, {'avg', 'var'});
%         HGP = data_filt{1};
%         
%         %Average over individual bands
%         for triali = 1 : length(data_filt_norm{freqi}.trial)
%             meanHGP = zeros(size(data_filt_norm{1}.trial{1}, 1), size(data_filt_norm{1}.trial{1}, 2), length(data_filt));
%             
%             for freqi = 1 : length(data_filt_norm)
%                 meanHGP(:, :, freqi) = data_filt_norm{freqi}.trial{triali};
%             end
%             
%             HGP.trial{triali} = mean(meanHGP, 3);
%         end
%     end
%     
%     %Average over trials
%     HGP.avg = zeros(size(HGP.trial{1}, 1), size(HGP.trial{1}, 2), length(HGP.trial));
%     for triali = 1 : length(HGP.trial)
%         HGP.avg(:, :, triali) = HGP.trial{triali};
%     end
%     
%     %Add missing info
%     HGP.elec = reref.elec;
%     HGP.elec_mni_frv = reref.elec_mni_frv;
%     HGP.label_all = reref.label_all;
%     HGP.elec_all = reref.elec_all;
%     HGP.elec_mni_frv_all = reref.elec_mni_frv_all;
%     
%     %Save
%     save([res_path subnips{subi} '/' subnips{subi} '_HGP_' extract_method '.mat'], 'HGP', '-v7.3');


    

 






