%This is the main script to plot the results of the PCA.
%Project: ECoG_WM
%Author: D.T.
%Date: 07 June 2021

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

blc = 0; %normalization: yes or no
pca_method = 'pca'; %eigendecomposition or pca_con or pca
dropoff = 1; %corrected for 1/f or not?
extract_method = 'alex';

var_thresh = 95;

%% Define important parameters
frequency = 'HGP';

if strcmp(frequency, 'fullSpectrum')
    latencies = [-0.14, 4.3]; %to account for the lower frequencies
    times = [-0.14 : 0.01 : 4.3];
    freqs = [8, 180];
elseif strcmp(frequency, 'HGP')
    latencies =  [-0.2, 4.5];
    freqs = [70 150];
end

%% Loop over subjects
figure;

for subi = 1 : length(subnips)
    
    %Load data
    pc{subi} = load([res_path subnips{subi} '/' subnips{subi} '_PCA_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '_pc.mat'], 'pc');
    proj{subi} = load([res_path subnips{subi} '/' subnips{subi} '_PCA_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '_proj.mat'], 'proj');
    eigvals{subi} = load([res_path subnips{subi} '/' subnips{subi} '_PCA_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '_eigvals.mat'], 'eigvals');
    var_expl{subi} = load([res_path subnips{subi} '/' subnips{subi} '_PCA_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '_var_expl.mat'], 'var_expl');
    
    
    %% Loop over channels 
    for chani = 1 : length(pc{subi}.pc)
        
        %Identify number of components accounting for 95% of the variance
        cumsum_tmp = cumsum(var_expl{subi}.var_expl{chani});
        row = find(cumsum_tmp < var_thresh);   
        n_comps{subi}(chani)  = length(row)+1;
        
    end

    %% Plot
    subplot(3, 4, subi);
    bar(n_comps{subi});
    xlabel('Channel number');
    ylabel('Number of components');
    box off;
end

printfig(gcf, [0, 0, 30, 20], ['/media/darinka/Data0/iEEG/Results/PCA/Figures/VarianceExplained_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '.tiff']);

%% Plot each of the top components for each channel individually
for subi = 1 : length(subnips)
    
    %Load data
    
    if dropoff == 0
        load([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_final.mat']);
    
        %Prepare data for pca (i.e., select frequencies and time range, and
        %apply normalization if wanted)
        cfg = [];
        cfg.latency = latencies;
        cfg.frequency = freqs;
    
        freq = ft_selectdata(cfg, freq);    %Prepare data for pca (i.e., select frequencies and time range, and
    else
        if strcmp(frequency, 'fullSpectrum')
            load([res_path subnips{subi} '/' subnips{subi} '_freqSpectrum_corrected_' extract_method '.mat']);
        else
            load([res_path subnips{subi} '/' subnips{subi} '_highGammaPower_corrected_' extract_method '.mat']);
        end
    end
    
    figure;
    for chani = 1 : length(pc{subi}.pc)
        subplot(5, 9, chani);
        
        plot(pc{subi}.pc{chani}(:, 1:n_comps{subi}));
        
        XTicks = ([1 :8 : size(freq.freq, 2)]);
        xticks(XTicks);
        XTickLabels = round(freq.freq(XTicks));
        xticklabels({num2str(XTickLabels(:))});

        xlabel('Hz');
        ylabel('Weight');
        
        title(freq.label{chani});
        
        if chani == length(pc{subi}.pc)
            legend;
        end
    end
    
    printfig(gcf, [0, 0, 50, 30], ['/media/darinka/Data0/iEEG/Results/PCA/Figures/' subnips{subi} '_TopComponents_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '.tiff']);
    close(gcf);
    
    figure;
    for chani = 1 : length(pc{subi}.pc)
        subplot(5, 9, chani);
        
        plot(pc{subi}.pc{chani}(:, 1:3));
        
        XTicks = ([1 :8 : size(freq.freq, 2)]);
        xticks(XTicks);
        XTickLabels = round(freq.freq(XTicks));
        xticklabels({num2str(XTickLabels(:))});

        xlabel('Hz');
        ylabel('Weight');
        
        title(freq.label{chani});
        
        if chani == length(pc{subi}.pc)
            legend;
        end
    end
    
    printfig(gcf, [0, 0, 50, 30], ['/media/darinka/Data0/iEEG/Results/PCA/Figures/' subnips{subi} '_Top3Components_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '_dropOffCorr_' num2str(dropoff) '.tiff']);
    close(gcf);
end

%% Project original data back into top component space
for subi = 1 : length(subnips)
  
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_final.mat']);
    
    %Prepare data for pca (i.e., select frequencies and time range, and
    %apply normalization if wanted)
    cfg = [];
    cfg.latency = latencies;
    cfg.frequency = freqs;
    
    freq = ft_selectdata(cfg, freq);
    
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
    
    %Compute trial-average (to more closely simulate the data pca was
    %performed on)
    cfg = [];
    freq_avg = ft_freqdescriptives(cfg, freq_norm);
    
    clear('freq');
    
    %Project into component space (without baseline correction)
    for chani = 1 : length(pc{subi}.pc)
        dat = squeeze(freq_norm.powspctrm(:, chani, :, :)); %actual data
        dat_avg = squeeze(freq_avg.powspctrm(chani, :, :)); %average data
        comps = n_comps{subi}(chani);
        
        pc_tmp = zeros(size(pc{subi}.pc{chani})); 
        pc_tmp(:, 1:comps) = pc{subi}.pc{chani}(:, 1:comps);
        %pc_tmp = pc_tmp';
        
        for  triali = 1 : size(dat, 1)
            cdat{chani}(triali,  :, :) = pc_tmp * squeeze(dat(triali, :, :));
        end
        
        cdat_avg{chani} = pc_tmp * squeeze(dat_avg);
    end
    
%     %Apply baseline correction
%     tmp = zeros(size(freq_norm.powspctrm));
%     
%     for chani = 1 : size(tmp, 2)
%         tmp(:, chani, :, :) = cdat{chani};
%     end
%     
%     freq_norm.powspctrm = tmp;
%     
%     cfg = [];
%     cfg.baseline = [-0.14, 0.05];
%     cfg.baselinetype = 'db';
%     
%     freq_norm = ft_freqbaseline(cfg, freq_norm);
%     
%     for chani = 1 : size(freq_norm.powspctrm, 2)
%         cdat_blc{chani} = squeeze(freq_norm.powspctrm(:, chani, :, :));
%     end
    
    
    %Save
    save(['/media/darinka/Data0/iEEG/Results/PCA/' subnips{subi}  '_compData_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '.mat'], 'cdat', '-v7.3');
    save(['/media/darinka/Data0/iEEG/Results/PCA/' subnips{subi}  '_compData_avg_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '.mat'], 'cdat', '-v7.3');
    clear('cdat', 'cdat_avg', 'freq_norm');

end

%% Plot componenents of each channel
for subi =  1 : length(subnips)
    
    %Load data
     load(['/media/darinka/Data0/iEEG/Results/PCA/' subnips{subi}  '_compData_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '.mat'], 'cdat', '-v7.3');
     load(['/media/darinka/Data0/iEEG/Results/PCA/' subnips{subi}  '_compData_blc_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '.mat'], 'cdat', '-v7.3');

    %Plot (projection onto single trials): Leads to negative values for
    %power!!!
    figure;
    
    for chani = 1 : length(cdat)
        subplot(5, 8, chani);
        imagesc(squeeze(mean(cdat{chani}))); %average over trials
        set(gca, 'YDir', 'normal');
        YTicks = ([1 :5 : size(cdat_avg{1}, 1)]);
        yticks(YTicks);
        YTickLabels = round(freq_norm.freq(YTicks));
        yticklabels({num2str(YTickLabels(:))});
        xticks([15, 445]);
        xticklabels({num2str(times(15)), num2str(times(445))});
        colorbar;
    end
    
    printfig(gcf, [0, 0, 50, 30], ['/media/darinka/Data0/iEEG/Results/PCA/Figures/' subnips{subi} '_ComponentTimecourse_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '.tiff']);

    %Plot (projection onto trial-mean)
    figure;
    
    for chani = 1 : length(cdat_avg)
        subplot(5, 8, chani);
        imagesc(cdat_avg{chani}); %average over trials
        set(gca, 'YDir', 'normal');
        YTicks = ([1 :5 : size(cdat_avg{1}, 1)]);
        yticks(YTicks);
        YTickLabels = round(freq_norm.freq(YTicks));
        yticklabels({num2str(YTickLabels(:))});
        xticks([15, 445]);
        xticklabels({num2str(times(15)), num2str(times(445))});
        colorbar;
    end
    
    printfig(gcf, [0, 0, 50, 30], ['/media/darinka/Data0/iEEG/Results/PCA/Figures/' subnips{subi} '_ComponentTimecourse_avg_' pca_method '_' frequency '_baselineCorr_' num2str(blc) '.tiff']);

end



