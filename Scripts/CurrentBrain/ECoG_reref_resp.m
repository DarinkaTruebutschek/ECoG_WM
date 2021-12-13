%Purpose: Rereference the epochs to the subjects' response (i.e., RT = 0)
%Project: ECoG_WM
%Author: D.T.
%Date: 09 December 2019

clear all;

close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
sf = 1000;

if sf == 250
    tmin = -4.0;
    tmax = 0; %this corresponds to the actual RT of the subject

    time = [tmin : 0.004 : tmax];
elseif sf == 100
    tmin = -4.0;
    tmax = 0;
    
    time = [tmin : 0.01 : tmax];
elseif sf == 1000
    tmin = -4.0;
    tmax = 0;
    
    time = [tmin : 0.001 : tmax];
end

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP', 'HL'}; %subject KR has a different sampling frequency, to be checked carefully
%subnips = {'HS', 'KJ_I', 'LJ', 'MG', 'WS', 'KR', 'AS', 'AP'};
%subnips = {'CD'};

%% Load data
for subi = 1 : length(subnips)
    
    display(['Preparing subject: ' subnips{subi}]);
    
    %Load initial data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']);
    %reref = reref_anat;
    
    %Re-adjust time-axis (& re-epoch)
    cfg = [];
    for triali = 1 : length(reref.trial)
        cfg.offset(triali) = -((length(reref.time{triali}) - (0.45*reref.fsample))-1);
    end
    
    data_respLocked = ft_redefinetrial(cfg, reref);
    
    %Extract trialinfo field
    trialInfo_all = reref.trialInfo_all;
    data_respLocked = rmfield(data_respLocked, 'trialInfo_all');
    
    %Determine end sample of each trial and shift time axis to common
    %denominator
    for triali = 1 : length(data_respLocked.time)
        end_t(triali) = data_respLocked.time{triali}(end);
    end
    
    if numel(unique(end_t))
       display('ATTENTION! Adjusting time axis to facilitate following analyses');
            
       %my_difference = end_t - (0.); 
            
       %Adjust the measured differences
       for triali = 1 : length(data_respLocked.time)
           if end_t(triali) < 0
               tmp{triali} = data_respLocked.time{triali} + abs(end_t(triali));
           elseif end_t(triali) > 0
               tmp{triali} = data_respLocked.time{triali} - abs(end_t(triali));
           else
               tmp{triali} = data_respLocked.time{triali};
           end
       end
            
       %Re-check
       for triali = 1 : length(data_respLocked.time)
           end_t2(triali) = tmp{triali}(end);
       end
            
       display(num2str(unique(end_t2(triali))));
            
       %pause;
            
       data_respLocked.time = tmp;
       
       clear tmp;
    end
    
    %Subselect that part of the data that should be used for any subsequent
    %analysis
    cfg = [];
    cfg.latency = [tmin, tmax];
    
    tmp = ft_selectdata(cfg, data_respLocked);
    
   if sf ~= 1000
        %Extract ERPs: Filter
        cfg = [];
        cfg.lpfilter = 30; %lowpass data at 30 Hz
    
        tmp2 = ft_preprocessing(cfg, tmp);
    
        %Extract ERPs: downsammple
        cfg = [];
        cfg.resamplefs = 100;
        %cfg.resamplefs = 250;
        cfg.detrend = 'no'; %detrending should only be used prior to TFA analysis, but not when looking at evoked fields
    
        data_respLocked = ft_resampledata(cfg, tmp2);
    else
        data_respLocked = tmp;
   end
    
    %Add necessary info to data file
    data_respLocked.elec_mni_frv = reref.elec_mni_frv;
    data_respLocked.label_all = reref.label_all;
    data_respLocked.elec_all = reref.elec_all;
    data_respLocked.elec_mni_frv_all = reref.elec_mni_frv_all;
    data_respLocked.trialInfo_all = trialInfo_all;
    %data.trialInfo_all = reref.trialInfo_all;

    %if sf ~= 1000
        %Timelock
        %cfg = [];
        %cfg.latency = [tmin, tmax];
    
        %erp{subi} = ft_timelockanalysis(cfg, data_respLocked);
    
        %Plot individual subjects' erps
        %figure;
        %plot(time, squeeze(mean(erp{subi}.avg)));
    
        %Save
        %save([res_path subnips{subi} '/' subnips{subi} '_frontal_respLocked_erp_100.mat'], 'data_respLocked', '-v7.3');
        %pause;
    %else 
        %Save
        %save([res_path subnips{subi} '/' subnips{subi} '_temporal_respLocked_erp_100.mat'], 'data_respLocked', '-v7.3');
        save([res_path subnips{subi} '/' subnips{subi} '_reref_respLocked.mat'], 'data_respLocked', '-v7.3');
    %end
    
    clear ('reref', 'tmp', 'tmp1', 'tmp2', 'data_respLocked', 'erp');
end


