%This is the main script to check whether the ECoG data are sufficiently
%time-locked, by first testing whether there is an evoked response and then
%extracting those components related to the visual response.
%Project: ECoG_WM
%Author: D.T.
%Date: 09 December 2019

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables

tmin = -0.421;
tmax = 4.499;

time = [tmin : 0.004 : tmax];

%% Define important variables
%subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP', 'HL'}; %subject KR has a different sampling frequency, to be checked carefully
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};

%% Load data
for subi = 1 : length(subnips)
    
    display(['Preparing subject: ' subnips{subi}]);
    
    %Load initial data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']);
    
    %Determine beginning sample of each trial and shift time axis to common
    %denominator
    for triali = 1 : length(reref.time)
        begin_t(triali) = reref.time{triali}(1);
    end
    
    if numel(unique(begin_t))
       display('ATTENTION! Adjusting time axis to facilitate following analyses');
            
       my_difference = begin_t - (-.45); 
            
       %Adjust the measured differences
       for triali = 1 : length(reref.time)
           tmp{triali} = reref.time{triali} - my_difference(triali);
       end
            
       %Re-check
       for triali = 1 : length(reref.time)
           begin_t2(triali) = tmp{triali}(1);
       end
            
       display(num2str(unique(begin_t2(triali))));
            
       %pause;
            
       reref.time = tmp;
    end
    
    %Subselect that part of the data that should be used for any subsequent
    %analysis
    cfg = [];
    cfg.latency = [-.45, tmax];
    
    tmp = ft_selectdata(cfg, reref);
    
    %Extract ERPs: Filter
    cfg = [];
    cfg.lpfilter = 30; %lowpass data at 30 Hz
    
    tmp2 = ft_preprocessing(cfg, tmp);
    
    %Extract ERPs: downsammple
    cfg = [];
    cfg.resamplefs = 250;
    cfg.detrend = 'no'; %detrending should only be used prior to TFA analysis, but not when looking at evoked fields
    
    data = ft_resampledata(cfg, tmp2);
    
    %Add necessary info to data file
    data.elec_mni_frv = reref.elec_mni_frv;
    data.label_all = reref.label_all;
    data.elec_all = reref.elec_all;
    data.elec_mni_frv_all = reref.elec_mni_frv_all;
    %data.trialInfo_all = reref.trialInfo_all;

    %Timelock
    cfg = [];
    cfg.latency = [tmin, tmax];
    
    erp{subi} = ft_timelockanalysis(cfg, data);
    
    %Plot individual subjects' erps
    figure;
    plot(time, squeeze(mean(erp{subi}.avg)));
    
    %Save
    save([res_path subnips{subi} '/' subnips{subi} '_erp.mat'], 'data', '-v7.3');
    %pause;
    
    clear ('tmp', 'tmp1', 'tmp2', 'data');
end

%% Plot average erp (for anatomically-defined subsets of channels)
