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
    tmin = -4.5; %this corresponds to the onset of the cue, 0 being the onset of the probe screen
    tmax = 0.5; %this corresponds to 500 ms into the probe screen
    
    time = [tmin : 0.004 : tmax];
elseif sf == 100
    tmin = -4.5;
    tmax = 0.5;
    
    time = [tmin : 0.01 : tmax];
elseif sf == 1000
    tmin = -4.5;
    tmax = 0.5;
    
    time = [tmin : 0.001 : tmax];
end

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP', 'HL'}; %subject KR has a different sampling frequency, to be checked carefully
%subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP', 'CD', 'HL'};
%subnips = {'LJ'};
%subnips = {'HS', 'KJ_I', 'LJ', 'MG', 'WS', 'KR', 'AS', 'AP'};

%% Load data
for subi = 1 : length(subnips)
    
    display(['Preparing subject: ' subnips{subi}]);
    
    %Load initial data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']);
    %reref = reref_anat;
    
    load([behavior_path subnips{subi} '_memory_behavior_combined.mat']);
    
    %Check which trials have less than 5 sec after cue presentation  
    for triali = 1 : length(reref.time)
        trial_end{subi}(triali) = reref.time{triali}(end);
    end
    
    trial_excluded{subi} = trial_end{subi} < 5;
    
    %Exclude any trials with less than 500 ms in probe period
    tmp = reref;

    tmp.trial = reref.trial(~trial_excluded{subi});
    tmp.time = reref.time(~trial_excluded{subi});
    tmp.sampleInfo = reref.sampleInfo(~trial_excluded{subi}, :);
    tmp.alltrig = reref.alltrig(~trial_excluded{subi}, :);
    
    %Exclude the same from the behavioral log file
    trial_included_old = data_mem.EEG_included;
    trials_excluded = find(trial_excluded{subi});
    counter = 1;
    
    for triali = 1 : length(trial_included_old)
        if trial_included_old(triali) == 1
            if ismember(counter, trials_excluded)
                trial_included_new(triali) = 0;
                counter = counter + 1;
            else
                trial_included_new(triali) = 1;
                counter = counter + 1;
            end
        else
            trial_included_new(triali) = 0;
        end
    end
    
    trial_included_new = trial_included_new';
    data_mem.trials_included_probe = trial_included_new;
    
    save([behavior_path subnips{subi} '_temporal_memory_behavior_combined_forProbes.mat'], 'data_mem');
    
    clear('reref');
    reref = tmp;
    
    clear('data_mem', 'tmp', 'trial_included_new');

    %Re-adjust time-axis (& re-epoch)
    cfg = [];
    for triali = 1 : length(reref.trial)
        cfg.offset(triali) = tmin*reref.fsample;
        %cfg.offset(triali) = -((length(reref.time{triali}) - (0.45*reref.fsample))-1);
    end
    
    data_probeLocked = ft_redefinetrial(cfg, reref);
    
    %Extract trialinfo field
    trialInfo_all = reref.trialInfo_all;
    data_probeLocked = rmfield(data_probeLocked, 'trialInfo_all');
    
    %Determine end sample of each trial and shift time axis to common
    %denominator
    for triali = 1 : length(data_probeLocked.time)
        begin_t(triali) = data_probeLocked.time{triali}(1);
    end
    
    if numel(unique(begin_t))
       display('ATTENTION! Adjusting time axis to facilitate following analyses');
            
       %Adjust the measured differences
       for triali = 1 : length(data_probeLocked.time)
           my_difference = begin_t(triali) + 4.9500;
           
           if my_difference < 0
               tmp{triali} = data_probeLocked.time{triali} + abs(my_difference);
           elseif my_difference > 0
               tmp{triali} = data_probeLocked.time{triali} - abs(my_difference);
           else
               tmp{triali} = data_probeLocked.time{triali};
           end
       end
            
       %Re-check
       for triali = 1 : length(data_probeLocked.time)
           begin_t2(triali) = tmp{triali}(1);
       end
            
       display(num2str(unique(begin_t2(triali))));
            
       %pause;
            
       data_probeLocked.time = tmp;
       
       clear tmp;
   end
    
    %Subselect that part of the data that should be used for any subsequent
    %analysis
    cfg = [];
    cfg.latency = [tmin, tmax];
    
    tmp = ft_selectdata(cfg, data_probeLocked);
    
%     if sf == 1000
%         %Extract ERPs: Filter
%         cfg = [];
%         cfg.lpfilter = 30; %lowpass data at 30 Hz
%     
%         tmp2 = ft_preprocessing(cfg, tmp);
%     
%         %Extract ERPs: downsammple
%         cfg = [];
%         cfg.resamplefs = 100;
%         %cfg.resamplefs = 250;
%         cfg.detrend = 'no'; %detrending should only be used prior to TFA analysis, but not when looking at evoked fields
%     
%         data_probeLocked = ft_resampledata(cfg, tmp2);
%     else
%         data_probeLocked = tmp;
%     end
    
    %Add necessary info to data file
    data_probeLocked.elec_mni_frv = reref.elec_mni_frv;
    data_probeLocked.label_all = reref.label_all;
    data_probeLocked.elec_all = reref.elec_all;
    data_probeLocked.elec_mni_frv_all = reref.elec_mni_frv_all;
    data_probeLocked.trialInfo_all = trialInfo_all;
    %data.trialInfo_all = reref.trialInfo_all;

%     if sf == 1000
%         %Timelock
%         cfg = [];
%         cfg.latency = [tmin, tmax];
%     
%         erp{subi} = ft_timelockanalysis(cfg, data_probeLocked);
%     
%         %Plot individual subjects' erps
%         figure;
%         plot(erp{subi}.time, squeeze(mean(erp{subi}.avg)));
%         line([0, 0], [-5, 5]); %probe onset
%         line([-3, -3], [-5, 5]); %memory onset
%         line([-4.5, -4.5], [-5, 5]); %memory onset
%         
%     
%         %Save
%         save([res_path subnips{subi} '/' subnips{subi} '_temporal_probeLocked_erp_100_longEpoch.mat'], 'data_probeLocked', '-v7.3');
%         %pause;
%     else 
%         %Save
%         %save(c, 'data_probeLocked', '-v7.3');
%     end
    
    %Save
    save([res_path subnips{subi} '/' subnips{subi} '_reref_probeLocked_longEpoch.mat'], 'data_probeLocked', '-v7.3');
    
    clear ('reref', 'tmp', 'tmp1', 'tmp2', 'data_probeLocked', 'erp');
end


