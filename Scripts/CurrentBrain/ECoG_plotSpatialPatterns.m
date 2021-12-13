%This script projects the coefficients of the spatial pattern decoding onto
%the mni standard brain.
%Project: ECoG_WM
%Author: D.T.
%Date: 14 Sept 2021

function ECoG_plotSpatialPatterns(decCond, filename,fmethod)
%% Specify important variables

subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

hemi = 'left';
viewside = 'lateral';
projectToLeft = 1; %project electrodes from the right hemisphere to the left?
normalization = 1; %normalize within-subject or not
maskSigTimes = 1; %mask any non-significant time points (within-subject) & just plot the raw sig scores

decCond = decCond;
filename = filename;
fmethod = fmethod;

%Timebins & significant time windows of interest
if strcmp(fmethod, 'erp_100')
    timeBins_labels = {'Baseline', 'Cue', 'Delay 1', 'Items', 'Delay 2'};
    timebins = [-.2, 0; 0, 0.5; 0.5, 1.5; 1.5 2.5; 2.5, 4.5];
%     timebins = [-.2, -.1; -.1, 0; 0, .1; .1, .2; .2, .3; .3, .4; .4, .5; .5, .6; .6, .7; .7, .8; .8, .9; .9, 1.; ...
% 		1., 1.1; 1.1, 1.2; 1.2, 1.3; 1.3, 1.4; 1.4, 1.5; 1.5, 1.6; 1.6, 1.7; 1.7, 1.8; 1.8, 1.9; 1.9, 2.0; ...
% 		2., 2.1; 2.1, 2.2; 2.2, 2.3; 2.3, 2.4; 2.4, 2.5; 2.5, 2.6; 2.6, 2.7; 2.7, 2.8; 2.8, 2.9; 2.9, 3.0; ...
% 		3., 3.1; 3.1, 3.2; 3.2, 3.3; 3.3, 3.4; 3.4, 3.5; 3.5, 3.6; 3.6, 3.7; 3.7, 3.8; 3.8, 3.9; 3.9, 4.0; ...
% 		4., 4.1; 4.1, 4.2; 4.2, 4.3; 4.3, 4.4; 4.4, 4.5];
    timeline = [-0.45 : 0.01 : 4.49];
    if strcmp(decCond, 'cue_diag')
        sigTimes = [0.49, 0.64; 0.76, 0.88];
    elseif strcmp(decCond, 'itemPos_diag')
        sigTimes = [1.71, 3.45];
    elseif strcmp(decCond, 'indItems_diag') | strcmp(decCond, 'indItems_trainCue0_testCue0_diag') | strcmp(decCond, 'indItems_trainCue1_testCue1_diag')
        sigTimes = [1.75, 2.11; 2.13, 2.29; 2.47, 2.56; 2.58, 2.66; 2.68, 2.77; 2.87, 3.04];
    elseif strcmp(decCond, 'load_diag')
        sigTimes = [1.75, 2.55; 2.57, 3.26];
    elseif strcmp(decCond, 'probeID_diag')
    elseif strcmp(decCond, 'probe_diag')
    elseif strcmp(decCond, 'buttonPress_diag')
    end
elseif strcmp(fmethod, 'probeLocked_erp_100_longEpoch')
    timeBins_labels = {'Cue', 'Delay 1', 'Items', 'Delay 2', 'Probe'};
    timebins = [-4.5, -4; -4, -3; -3, -2; -2, 0; 0, 0.5];
%     timebins = [-4.5, -4.4; -4.4, -4.3; -4.3, -4.2; -4.2, -4.1; -4.1, -4.0; ... 
% 		-4.0, -3.9; -3.9, -3.8; -3.8, -3.7; -3.7, -3.6; -3.6, -3.5; -3.5, -3.4; -3.4, -3.3; -3.3, -3.2; -3.2, -3.1; -3.1, -3.0; ...
% 		-3.0, -2.9; -2.9, -2.8; -2.8, -2.7; -2.7, -2.6; -2.6, -2.5; -2.5, -2.4; -2.4, -2.3; -2.3, -2.2; -2.2, -2.1; -2.1, -2.0; ...
% 		-2.0, -1.9; -1.9, -1.8; -1.8, -1.7; -1.7, -1.6; -1.6, -1.5; -1.5, -1.4; -1.4, -1.3; -1.3, -1.2; -1.2, -1.1; -1.1, -1.0; ...
% 		-1.0, -0.9; -0.9, -0.8; -0.8, -0.7; -0.7, -0.6; -0.6, -0.5; -0.5, -0.4; -0.4, -0.3; -0.3, -0.2; -0.2, -0.1; -0.1, 0.0; ...
% 		0.0, 0.1; 0.1, 0.2; 0.2, 0.3; 0.3, 0.4; 0.4, 0.5];
    timeline = [-4.5 : 0.01 : 0.5];
    if strcmp(decCond, 'cue_diag')
        sigTimes = [-4.01, -3.85];
    elseif strcmp(decCond, 'itemPos_diag')
        sigTimes = [-2.83, -1.16; 0.36, 0.5];
    elseif strcmp(decCond, 'indItems_diag')
        sigTimes = [-2.75, -2.39; -2.37, -2.21; -2.04, -1.94; -1.92, -1.73; -1.63, -1.46];
    elseif strcmp(decCond, 'load_diag')
        sigTimes = [-2.75, -1.95; -1.93, -1.36; -0.05, 0.06; 0.27, 0.5];
    elseif strcmp(decCond, 'probeID_diag')
        sigTimes = [0.29, 0.5];
    elseif strcmp(decCond, 'probe_diag')
        sigTimes = [-0.09, -0.03; 0.33, 0.5];
    elseif strcmp(decCond, 'buttonPress_diag')
    end
elseif strcmp(fmethod, 'respLocked_erp_100')
    timebins = [-4, -3.5; -3.5, -3; -3, -2.5; -2.5, -2; -2, -1.5; -1.5, -1; -1, -.5; -.5, 0];
%     timebins = [-4.0, -3.9; -3.9, -3.8; -3.8, -3.7; -3.7, -3.6; -3.6, -3.5; -3.5, -3.4; -3.4, -3.3; -3.3, -3.2; -3.2, -3.1; -3.1, -3.0; ...
% 		-3.0, -2.9; -2.9, -2.8; -2.8, -2.7; -2.7, -2.6; -2.6, -2.5; -2.5, -2.4; -2.4, -2.3; -2.3, -2.2; -2.2, -2.1; -2.1, -2.0; ...
% 		-2.0, -1.9; -1.9, -1.8; -1.8, -1.7; -1.7, -1.6; -1.6, -1.5; -1.5, -1.4; -1.4, -1.3; -1.3, -1.2; -1.2, -1.1; -1.1, -1.0; ...
% 		-1.0, -0.9; -0.9, -0.8; -0.8, -0.7; -0.7, -0.6; -0.6, -0.5; -0.5, -0.4; -0.4, -0.3; -0.3, -0.2; -0.2, -0.1; -0.1, 0.0];
    timeline =  [-4 : 0.01 : 0];
    if strcmp(decCond, 'cue_diag')
        sigTimes = [-0.33, -0.25; -0.14, -0.05];
    elseif strcmp(decCond, 'itemPos_diag')
        sigTimes = [-2.73, -2.61; -0.67, -0.59; -0.52, -0.42; -0.4, -0.18; -0.13, 0.];
    elseif strcmp(decCond, 'indItems_diag')
    elseif strcmp(decCond, 'load_diag')
        sigTimes = [-3.06, -2.94; -2.09, -2.0; -0.65, -0.6; -0.46, -0.35; -0.3, 0.];
    elseif strcmp(decCond, 'probeID_diag')
    elseif strcmp(decCond, 'probe_diag')
        sigTimes = [-0.32, -0.17];
    elseif strcmp(decCond, 'buttonPress_diag')
        sigTimes = [-0.55, 0];
    end
end

%For plotting
%my_colors = flipud(cbrewer('div','Spectral', 12));
my_colors = cbrewer('seq','PuRd', 12);

%% Import necessary paths
ECoG_setPath;

%% Load data
for subi = 1 : length(subnips)
    
    display(['Loading data for subject ', subnips{subi}]);
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']); %load preprocessed data including the necessary channel information

    if strcmp(fmethod, 'erp_100')
        tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_' decCond '_' filename '_scores.mat']);
    elseif strcmp(fmethod, 'probeLocked_erp_100_longEpoch')
        tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_' decCond '_' filename '_scores.mat']);
    elseif strcmp(fmethod, 'respLocked_erp_100')
        tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_' decCond '_' filename '_scores.mat']);
    end

    data{subi} = tmp{subi}.data;
    display(num2str(size(data{subi})));
    
    %Average over multiple dimensions if they exist
    if ndims(data{subi}) == 3
        display('Averaging over dimensions ...');
        
        %Determine smalles dimension
        minDim = min(size(data{subi}));
        [~, minDim] = find(size(data{subi}) == minDim);
        data{subi} = squeeze(mean(data{subi}, minDim));
    end
    
    %Mask any non-significant time points & then plot raw scores
    if maskSigTimes
        timeline_sig = timeline;
    
        for sigi =  1 : size(sigTimes, 1)
            ind1 = nearest(timeline,sigTimes(sigi, 1));
            ind2 = nearest(timeline,sigTimes(sigi, 2));
            
            timeline_sig(ind1:ind2) = nan;
        end
        
        timeline_tmp = repmat(timeline_sig, [size(data{subi}, 1), 1]);
        timeline_tmp = ~isnan(timeline_tmp);
        
        data{subi}(timeline_tmp) = nan;
    end
    
    
%     %Normalize coefficients to render them comparable across subjects
%     if normalization
%         tmp1 = data{subi}(:);
%         tmp1 = normalize(tmp1);
%         data{subi} = reshape(tmp1, [size(data{subi}, 1), size(data{subi}, 2)]);
%     end
end

%% Project all of the subjects' individual electrodes into standard mni space
for subi = 1 : length(subnips) 
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']); %load preprocessed data including the necessary channel information
    
    for bini = 1 : length(timebins)
        ind1  = nearest(timeline,timebins(bini, 1));
        ind2  = nearest(timeline, timebins(bini, 2));
        ind2 = ind2-1;
            
        data_tmp{subi}(bini, :) =  nanmean(data{subi}(:, ind1:ind2), 2);
    end
        
    data{subi} = data_tmp{subi};
    
    %Normalize coefficients to render data comparable across subjects
    if normalization
        tmp1 = data{subi}(:);
        tmp1 = normalize(tmp1);
        data{subi} = reshape(tmp1, [size(data{subi}, 1), size(data{subi}, 2)]);
    end
    
    %Take absolute values
    data{subi} = abs(data{subi});
            
    %Sanity check: Does the number of channels imported via Python
    %correspond to the number of channels included in the Matlab data
    %struct?
    if size(data{subi}, 2) ~= size(reref.label, 1)
        display('ERROR: Channel dimensions do not match.');
    end
    
    %Select channels
    [channels_left{subi}, channels_right{subi}] = ECoG_subjInfo(subnips{subi}, 'all');
    
    if strcmp(hemi, 'left')
        pial_file = 'pial_left.mat';
        
        if ~projectToLeft
            channelSelection{subi} = {channels_left{subi}};
        else
            channelSelection{subi} = {[channels_left{subi}, channels_right{subi}]};
        end
    elseif strcmp(hemi, 'right')
        pial_file = 'pial_right.mat';
        channelSelection{subi} = {channels_right{subi}};
    end
    
    %Extract infos about channels
    [channels{subi}, ind{subi}] = ECoG_splitElectrodes(reref.elec_mni_frv, channelSelection{subi}{1});
end

%Project all channels onto the same hemisphere
if projectToLeft
    for subi = 1 : length(subnips)
        tmp = channels{subi}.chanpos(:, 1) > 0;
        channels{subi}.chanpos(tmp, 1) = channels{subi}.chanpos(tmp, 1) .* (-1);
    end
end

%Concatenate to be able to apply colormap across all electrodes
X_pos = cell(1, size(data{1}, 1));
Y_pos = cell(1, size(data{1}, 1));
Z_pos = cell(1, size(data{1}, 1));
dat2plot = cell(1, size(data{1}, 1));

for toi_i = 1 : size(data{1}, 1)
    for subi = 1 : length(subnips)
        display(subnips{subi});
        if ~isempty(channels{subi}.chanpos)
            tmp_X = channels{subi}.chanpos(:, 1);
            tmp_Y = channels{subi}.chanpos(:, 2);
            tmp_Z = channels{subi}.chanpos(:, 3);
       
            tmp_data = data{subi}(toi_i, ind{subi})';
        else
            tmp_X = nan;
            tmp_Y = nan;
            tmp_Z = nan;
        
            tmp_data = nan;
        end
    
        X_pos{toi_i} = [X_pos{toi_i}; tmp_X];
        Y_pos{toi_i} = [Y_pos{toi_i}; tmp_Y];
        Z_pos{toi_i} = [Z_pos{toi_i}; tmp_Z];
    
        dat2plot{toi_i} = [dat2plot{toi_i}; tmp_data];
    
        clear ('tmp_X', 'tmp_Y', 'tmp_Z', 'tmp_data');
    end
end

%% Plot raw coefficients
%Alphas
for toi_i = 1 : size(data{1}, 1)
    my_alphas{toi_i} = isnan(dat2plot{toi_i});
end

%Colormap
if strcmp(fmethod, 'respLocked_erp_100')
    if strcmp(decCond, 'buttonPress_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'probe_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'probeID_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'load_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'indItems_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'itemPos_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'cue_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    end
elseif (strcmp(fmethod, 'erp_100')) | (strcmp(fmethod, 'probeLocked_erp_100_longEpoch'))
    if strcmp(decCond, 'buttonPress_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'probe_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'probeID_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'load_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'indItems_diag') | strcmp(decCond, 'indItems_trainCue0_testCue0_diag') | strcmp(decCond, 'indItems_trainCue1_testCue1_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'itemPos_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'cue_diag')
        c_min = 0;
        c_max = max(max([dat2plot{:}]));
    end
end

figure;
for toi_i = 1 : length(timebins)
    
    if strcmp(fmethod, 'respLocked_erp_100')
        subplot(2, 5, toi_i);
        %subplot(6, 10, toi_i);
    elseif strcmp(fmethod, 'erp_100')
        subplot(2, 5, toi_i);
        %subplot(6, 10, toi_i);
    elseif strcmp(fmethod, 'probeLocked_erp_100_longEpoch')
        subplot(2, 5, toi_i);
        %subplot(6, 10, toi_i);
    end
    
    colormap(my_colors);
    caxis([c_min, c_max]);
    
    hold on
    pial = ft_read_headshape(['/usr/local/Fieldtrip/fieldtrip-20190329/template/anatomy/surface_' pial_file]);  
    h = ft_plot_mesh(pial, 'facecolor', [.9, .9, .9], 'facealpha', .45);
    set(get(get(h, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');

    %Define viewpoint
    [theta, phi] = ECoG_defineView(hemi, viewside);
    view(theta, phi);

    %Define lighting
    material([.2, .9, .15, 10, 1])
    lighting gouraud;
    view_position = ECoG_defineLight(theta, phi);

    %camlight;
    tmp = light('Position', view_position);

    scatter3(X_pos{toi_i}, Y_pos{toi_i}, Z_pos{toi_i}, 3, 'MarkerEdgeColor', [105, 105, 105] ./255); %stupid way to get black outline around electrodes
    scatter3(X_pos{toi_i}(my_alphas{toi_i}), Y_pos{toi_i}(my_alphas{toi_i}), Z_pos{toi_i}(my_alphas{toi_i}), 3, dat2plot{toi_i}(my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 0); %stupid way to adjust transparency of individual electrodes
    my_handle = scatter3(X_pos{toi_i}(~my_alphas{toi_i}), Y_pos{toi_i}(~my_alphas{toi_i}), Z_pos{toi_i}(~my_alphas{toi_i}), 3, dat2plot{toi_i}(~my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 1);

    if strcmp(fmethod, 'respLocked_erp_100')
        title(num2str(timebins(toi_i, 1)), 'FontName', 'Arial', 'FontWeight', 'normal', 'FontSize', 8);
    else
        title(timeBins_labels{toi_i}, 'FontName', 'Arial', 'FontWeight', 'normal', 'FontSize', 8);
    end  
end

%Add colorbar
subplot(2, 5, 10);
%subplot(6, 10, 60);
colorbar('TickLabels',{'0', '', num2str(c_max)});

%Save
savename = ['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/Figures/' decCond '_' filename '_SpatialPattern_' hemi '_' viewside '_sigCoefs.pdf'];
printfig(gcf, [0, 0, 20, 15], savename);
close all;
end


