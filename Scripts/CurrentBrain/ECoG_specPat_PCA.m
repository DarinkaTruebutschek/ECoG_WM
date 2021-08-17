%This is the main script to identify relevant components in the frequency
%domain using PCA.
%Project: ECoG_WM
%Author: D.T.
%Date: 26 May 2021

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

blc = 0; %normalization: yes or no
dropoff = 1; %data corrected for dropoff: yes or no
pca_method = 'pca'; %eigendecomposition or pca_con or pca
extract_method = 'alex';

%% Define important parameters
frequency = 'HGP';

if strcmp(frequency, 'fullSpectrum')
    latencies = [-0.14, 4.3]; %to account for the lower frequencies
    freqs = [8, 180];
elseif strcmp(frequency, 'HGP')
    latencies =  [-0.2, 4.5];
    freqs = [70 150];
end

%% Loop over subjects 
for subi = 1 : length(subnips)
    
    %Load data
    if dropoff == 0
        load([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_final.mat']);
    
        %Prepare data for pca (i.e., select frequencies and time range, and
        %apply normalization if wanted)
        cfg = [];
        cfg.latency = latencies;
        cfg.frequency = freqs;
    
        freq = ft_selectdata(cfg, freq);
    
        %Plot (just for visualization)
        figure;
        imagesc(squeeze(mean(mean(freq.powspctrm))));
        colorbar;
    
        %Normalization (if wanted, to account for 1/f dropoff)
        if blc
            cfg = [];
            cfg.baseline = 'yes';
            cfg.baselinewindow = [-0.14, 0.05]; %take the entire window?
            cfg.baselinetype = 'db';
        
            freq_norm = ft_freqbaseline(cfg, freq);
        else
            freq_norm = freq;
        end
    
        %Plot again (just for visualization)
        figure;
        imagesc(squeeze(mean(mean(freq_norm.powspctrm))));
        colorbar;
    
        clear('freq')
    else
        if strcmp(frequency, 'fullSpectrum')
            load([res_path subnips{subi} '/' subnips{subi} '_freqSpectrum_corrected_' extract_method '.mat']);
        else
            load([res_path subnips{subi} '/' subnips{subi} '_highGammaPower_corrected_' extract_method '.mat']);
        end
        freq_norm = freq;
    end
    
    %% Do PCA (seperately for each channel & trial)
    for chani = 1 : length(freq_norm.label)
        display(['Performing PCA on channel: ' num2str(chani)]);
        
        cfg = [];
        cfg.channel = freq_norm.label{chani};
        
        tmp = ft_selectdata(cfg, freq_norm);
        freq_norm_sel = squeeze(tmp.powspctrm);
        clear('tmp');
        
        if strcmp(pca_method, 'eig')
            %Compute covariance matrices for each trial
            covar_tmp = zeros(size(freq_norm_sel, 2));
        
            for triali = 1 : length(size(freq_norm_sel, 1))
                tmp = cov(squeeze(freq_norm_sel(triali, :, :))');
                covar_tmp = covar_tmp + tmp;       
            end
        
            covar{chani} = covar_tmp ./ (size(freq_norm_sel, 1)); %divide by number of trials to get average

            %PCA via eigendecomposition
            [pc{chani}, eigvals{chani}] = eig(covar{chani});
            
            %Components are listed in increasing order, and converted here to
            %descending order for convenience
            pc{chani} = pc{chani}(:, end :-1 :1);
            eigvals{chani} = diag(eigvals{chani});
            eigvals_norm{chani} = 100*eigvals{chani}(end :-1 :1) ./ sum(eigvals{chani}); %convert to percent change
        elseif strcmp(pca_method, 'pca_conc')
            %Concatenate trials
            tmp1 = permute(freq_norm_sel, [2, 3, 1]);
            tmp2 = reshape(tmp1, [size(tmp1, 1), (size(tmp1, 2)*size(tmp1, 3))]);
            
            %Do PCA
            [pc{chani}, proj{chani}, eigvals{chani}, ~, var_expl{chani}] = pca(tmp2');
            clear('tmp1', 'tmp2');
        elseif strcmp(pca_method, 'pca')
            %Average across trials
            tmp = squeeze(mean(freq_norm_sel));
           
            %Do PCA
            [pc{chani}, proj{chani}, eigvals{chani}, ~, var_expl{chani}] = pca(tmp');
            clear('tmp');
        end
    end
            
    %Save
    save([res_path subnips{subi} '/' subnips{subi} '_PCA_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '_pc.mat'], 'pc');
    save([res_path subnips{subi} '/' subnips{subi} '_PCA_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '_proj.mat'], 'proj');
    save([res_path subnips{subi} '/' subnips{subi} '_PCA_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '_eigvals.mat'], 'eigvals');
    save([res_path subnips{subi} '/' subnips{subi} '_PCA_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '_var_expl.mat'], 'var_expl');
            
    clear('pc', 'proj', 'eigvals', 'var_expl');
    
end
        
