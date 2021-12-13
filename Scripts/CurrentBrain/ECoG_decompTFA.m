%This is the main script to decompose the ECoG data into its time-frequency
%spectrum
%Project: ECoG_WM
%Author: D.T.
%Date: 22 July 2019

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

tfa_method = 'wavelet_theta';
epoch = 'cueLocked';
%% Specify parameters to be used for time-frequency analysis
if strcmp(tfa_method, 'wavelet')
    minf = 2; 
    maxf = 240;
    nfreqs = 75;
    
    freqoi = logspace(log10(minf), log10(maxf), nfreqs);
    freqoi = unique(round(freqoi));
    
    %Chosen time window will last from -0.445s prior to cue onset to 150 ms
    %post probe onset
    if ~strcmp(epoch, 'respLocked')
        toi = [-0.44 : 0.01 : 4.650];
    else
        toi = [-4.0 : 0.01 : 0];
    end
elseif strcmp(tfa_method, 'wavelet_theta')
    minf = 4;
    maxf = 7;
    
    nfreqs = 4;
    freqoi = linspace(minf, maxf, nfreqs);
    
    %Chosen time window will last from -0.445s prior to cue onset to 150 ms
    %post probe onset
    if ~strcmp(epoch, 'respLocked')
        toi = [-0.44 : 0.01 : 4.650];
    else
        toi = [-4.0 : 0.01 : 0];
    end
end

%% Loop over subjects to decompose signal into time-frequency spectrum and save the resultant data file
for subi = 1 : length(subnips)
    
    if ~strcmp(epoch, 'respLocked')
        %if ~exist([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_final.mat'])
        if ~exist([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_theta.mat'])
        
            %Load initial data
            load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']);
    
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
            
                %pause;
            
                reref.time = tmp;
                
                clear('tmp');
            end
            
            %Select data to only include the time window of interest to begin
            %with
            cfg = [];
            cfg.latency = [toi(1), toi(end)];
        
            tmp = ft_selectdata(cfg, reref);
            
            cfg = [];
            cfg.method = 'tfr';
            cfg.output = 'pow'; % fourier to get complex values, pow to get power
            cfg.keeptrials = 'yes';
            cfg.foi = freqoi;
            cfg.toi = toi;
            cfg.width = 5; 
            cfg.pad = 'nextpow2';
            cfg.polyremoval = 1; %to demean & detrend
    
            freq = ft_freqanalysis(cfg, tmp);
    
            %Add missing info to frequency structure
            freq.elec = reref.elec;
            freq.elec_mni_frv = reref.elec_mni_frv;
            freq.label_all = reref.label_all;
            freq.elec_all = reref.elec_all;
            freq.elec_mni_frv_all = reref.elec_mni_frv_all;
    
            %Save
            save([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_theta.mat'], 'freq', '-v7.3');
            
            clear('tmp');       
        end         
    else
        %Load initial data
        load([res_path subnips{subi} '/' subnips{subi} '_respLocked_erp_1000.mat']);
        
        %Check sampling frequency to make sure 
        if data_respLocked.fsample ~= 1000
            disp('ATTENTION! Sample frequency deviates from 1000.');
        end
        
        %Remove trialInfo field 
        trialInfo_all = data_respLocked.trialInfo_all;
        data_respLocked = rmfield(data_respLocked, 'trialInfo_all');
        
        tmp = data_respLocked;
        
        cfg = [];
        cfg.method = 'tfr';
        cfg.output = 'pow'; % fourier to get complex values, pow to get power
        cfg.keeptrials = 'yes';
        cfg.foi = freqoi;
        cfg.toi = toi;
        cfg.width = 5; 
        cfg.pad = 'nextpow2';
        cfg.polyremoval = 1; %to demean & detrend
    
        freq = ft_freqanalysis(cfg, tmp);
    
        %Add missing info to frequency structure
        freq.elec = data_respLocked.elec;
        freq.elec_mni_frv = data_respLocked.elec_mni_frv;
        freq.label_all = data_respLocked.label_all;
        freq.elec_all = data_respLocked.elec_all;
        freq.elec_mni_frv_all = data_respLocked.elec_mni_frv_all;
        freq.trialInfo_all = trialInfo_all;
    
        %Save
        save([res_path subnips{subi} '/' subnips{subi} '_respLocked_tfa_wavelet.mat'], 'freq', '-v7.3');
    end
end

%% Interactively plot the time-frequency results 
for subi = 1 : length(subnips)
    
    %Load time-frequency results, headshape, and electrodes
    load([res_path subnips{subi} '/' subnips{subi} '_tfa_wavelet_theta.mat']);
    
    if isfield(freq.elec, 'coordsys')
        display(freq.elec.coordsys);
    else
        freq.elec.coordsys = 'acpc';
    end
    
    if strcmp(freq.elec.coordsys, 'unknown')
        freq.elec.coordsys = 'acpc';
    end
        
    pial_left = ft_read_headshape([mri_path subnips{subi} '/freesurfer/surf/lh.pial']);  
    pial_right = ft_read_headshape([mri_path subnips{subi} '/freesurfer/surf/rh.pial']);  

    if ~isfield(pial_left, 'coordsys')
        pial_left = ft_determine_coordsys(pial_left);
    end
    
    if ~isfield(pial_right, 'coordsys')
        pial_right = ft_determine_coordsys(pial_right);
    end   
    
    [channels_left, channels_right] = ECoG_subjInfo(subnips{subi}, 'depth');
    
    %Create the necessary layout
    cfg = [];
    cfg.headshape = [pial_left, pial_right];
    cfg.projection = 'orthographic';
    cfg.channel = [channels_left, channels_right];
    cfg.viewpoint = 'superior';
    %cfg.viewpoint = 'right';
    cfg.mask = 'convex';
    
    %Display all channels to select appropriate size of box
    display([channels_left, channels_right]);
    display(freq.elec.label);
    
    if ~isempty(channels_left) || ~isempty(channels_right)
        input_one = input('Select first channel. ');
        input_two = input('Select second channel. ');
    
        cfg.boxchannel = {input_one, input_two};
    
        lay = ft_prepare_layout(cfg, freq);
    
        %Express tfa at each channel in terms of relative change in activity
        %from baseline
        cfg = [];
        cfg.baseline = [-.45, -.1];
        cfg.baselinetype = 'db';
    
        freq_blc = ft_freqbaseline(cfg, freq);
    
        %Visualize tfa representations overlaid on 2D layout
        cfg = [];
        cfg.layout = lay;
        cfg.showoutline = 'yes';
    
        ft_multiplotTFR(cfg, freq_blc);
    else
        continue
    end
end