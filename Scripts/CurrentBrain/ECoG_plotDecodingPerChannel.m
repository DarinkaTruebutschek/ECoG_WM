%This script projects the results of the channel-wise item decoding onto
%standard mni brain.
%Project: ECoG_WM
%Author: D.T.
%Date: 03 February 2020

clear all;
close all;
clc;

%% Specify important variables

subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

hemi = 'left';
viewside = 'lateral';
projectToLeft = 1; %project electrodes from the right hemisphere to the left?
normalization = 0; %normalize within-subject or not
normalizeSigTimes = 1; %normalize significant time points or not?

%score_type = 'postItem';
decCond = 'buttonPress_diag';
%filename = 'respLocked_erp_100_TimDim_timeBin-100ms_nomeanSubtraction';
filename = 'respLocked_erp_100_spatialPatterns';
fmethod = 'respLocked_erp_100';

%For plotting
my_colors = flipud(cbrewer('div','Spectral', 12));


if (~strcmp(filename, 'erp_100_TimDim_timeBin-100ms_nomeanSubtraction')) & (~strcmp(filename, 'respLocked_erp_100_TimDim_timeBin-100ms_nomeanSubtraction')) & ...
        (~strcmp(filename, 'probeLocked_erp_100_longEpoch_TimDim_timeBin-100ms_nomeanSubtraction')) & ...
        (~strcmp(filename, 'erp_100_spatialPatterns')) & (~strcmp(filename, 'respLocked_erp_100_spatialPatterns')) & ...
        (~strcmp(filename, 'probeLocked_erp_100_longEpoch_spatialPatterns'))
    if ~strcmp(decCond, 'buttonPress_diag') && ~strcmp(decCond, 'probe_diag')
        timebins = {'Baseline', 'Cue', 'Delay 1', 'Items', 'Del2'};
    else
        timebins = {'-4.0s to -3.0s', '-3.0s to -2.0s', '-2.0s to -1.0s', '-1.0s to -0.5s', '-0.5s to 0s'};
    end
else
    if strcmp(fmethod, 'erp_100')
        timebins = [-.2, -.1; -.1, 0; 0, .1; .1, .2; .2, .3; .3, .4; .4, .5; .5, .6; .6, .7; .7, .8; .8, .9; .9, 1.; ...
		1., 1.1; 1.1, 1.2; 1.2, 1.3; 1.3, 1.4; 1.4, 1.5; 1.5, 1.6; 1.6, 1.7; 1.7, 1.8; 1.8, 1.9; 1.9, 2.0; ...
		2., 2.1; 2.1, 2.2; 2.2, 2.3; 2.3, 2.4; 2.4, 2.5; 2.5, 2.6; 2.6, 2.7; 2.7, 2.8; 2.8, 2.9; 2.9, 3.0; ...
		3., 3.1; 3.1, 3.2; 3.2, 3.3; 3.3, 3.4; 3.4, 3.5; 3.5, 3.6; 3.6, 3.7; 3.7, 3.8; 3.8, 3.9; 3.9, 4.0; ...
		4., 4.1; 4.1, 4.2; 4.2, 4.3; 4.3, 4.4; 4.4, 4.5];
    
        timebins_meaning = {[1, 2]; [3 : 7]};
        
        if strcmp(decCond, 'cue_diag')
            peakDecoding = 11; %this refers to the position of the timebin, i.e., 0.8-0.9; 0.87 s)
        end
    elseif strcmp(fmethod, 'respLocked_erp_100')
        timebins = [-4.0, -3.9; -3.9, -3.8; -3.8, -3.7; -3.7, -3.6; -3.6, -3.5; -3.5, -3.4; -3.4, -3.3; -3.3, -3.2; -3.2, -3.1; -3.1, -3.0; ...
		-3.0, -2.9; -2.9, -2.8; -2.8, -2.7; -2.7, -2.6; -2.6, -2.5; -2.5, -2.4; -2.4, -2.3; -2.3, -2.2; -2.2, -2.1; -2.1, -2.0; ...
		-2.0, -1.9; -1.9, -1.8; -1.8, -1.7; -1.7, -1.6; -1.6, -1.5; -1.5, -1.4; -1.4, -1.3; -1.3, -1.2; -1.2, -1.1; -1.1, -1.0; ...
		-1.0, -0.9; -0.9, -0.8; -0.8, -0.7; -0.7, -0.6; -0.6, -0.5; -0.5, -0.4; -0.4, -0.3; -0.3, -0.2; -0.2, -0.1; -0.1, 0.0];
    elseif strcmp(fmethod, 'probeLocked_erp_100_longEpoch')
        timebins = [-4.5, -4.4; -4.4, -4.3; -4.3, -4.2; -4.2, -4.1; -4.1, -4.0; ... 
		-4.0, -3.9; -3.9, -3.8; -3.8, -3.7; -3.7, -3.6; -3.6, -3.5; -3.5, -3.4; -3.4, -3.3; -3.3, -3.2; -3.2, -3.1; -3.1, -3.0; ...
		-3.0, -2.9; -2.9, -2.8; -2.8, -2.7; -2.7, -2.6; -2.6, -2.5; -2.5, -2.4; -2.4, -2.3; -2.3, -2.2; -2.2, -2.1; -2.1, -2.0; ...
		-2.0, -1.9; -1.9, -1.8; -1.8, -1.7; -1.7, -1.6; -1.6, -1.5; -1.5, -1.4; -1.4, -1.3; -1.3, -1.2; -1.2, -1.1; -1.1, -1.0; ...
		-1.0, -0.9; -0.9, -0.8; -0.8, -0.7; -0.7, -0.6; -0.6, -0.5; -0.5, -0.4; -0.4, -0.3; -0.3, -0.2; -0.2, -0.1; -0.1, 0.0; ...
		0.0, 0.1; 0.1, 0.2; 0.2, 0.3; 0.3, 0.4; 0.4, 0.5];
    end
end

%first_col = [0, 0, 0];
%remaining_col = cbrewer('seq', 'YlOrRd', 12);
%my_colors = [first_col; remaining_col];

%my_alphas = [0; ones(12, 1)]; %to add transparency to colormap

%my_colors = [my_colors, my_alphas];

%c_min = .505;
%c_max = .525;

%% Import necessary paths
ECoG_setPath;

%% Project all of the subjects' individual electrodes into standard mni space
for subi = 1 : length(subnips)
    
    display(['Loading data for subject ', subnips{subi}]);
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']); %load preprocessed data including the necessary channel information
    %tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_indItems_diag_' filename '_averageDecodingPerChannel_' score_type '.mat']);
    if (~strcmp(filename, 'erp_100_spatialPatterns')) & (~strcmp(filename, 'probeLocked_erp_100_longEpoch_spatialPatterns')) & (~strcmp(filename, 'respLocked_erp_100_spatialPatterns')) & (~strcmp(filename, 'respLocked_erp_100_TimDim_timeBin-100ms_nomeanSubtraction'))
        if strcmp(fmethod, 'erp_100')
            tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_' decCond '_' filename '_scores.mat']);
        elseif strcmp(fmethod, 'probeLocked_erp_100_longEpoch')
            tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_probeLocked_erp_timDim_' decCond '_' filename '_scores.mat']);
        elseif strcmp(fmethod, 'respLocked_erp_100')
            tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_respLocked_erp_timDim_' decCond '_' filename '_scores.mat']);
        end
    elseif (strcmp(filename, 'erp_100_spatialPatterns')) | (strcmp(filename,'respLocked_erp_100_spatialPatterns')) | (strcmp(filename, 'probeLocked_erp_100_longEpoch_spatialPatterns'))
        if strcmp(fmethod, 'erp_100')
            tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_' decCond '_' filename '_scores.mat']);
        elseif strcmp(fmethod, 'probeLocked_erp_100_longEpoch')
            tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_' decCond '_' filename '_scores.mat']);
        elseif strcmp(fmethod, 'respLocked_erp_100')
            tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_' decCond '_' filename '_scores.mat']);
        end
    elseif strcmp(filename, 'respLocked_erp_100_TimDim_timeBin-100ms_nomeanSubtraction')
        if strcmp(fmethod, 'erp_100')
            tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_'  filename '_' decCond '_' filename '_scores.mat']);
        elseif strcmp(fmethod, 'probeLocked_erp_100_longEpoch')
            tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_'  filename '_' decCond '_' filename '_scores.mat']);
        elseif strcmp(fmethod, 'respLocked_erp_100')
            tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_respLocked_erp_timDim_' decCond '_' filename '_scores.mat']);
        end
    end
    
    data{subi} = tmp{subi}.data;
    
    if (strcmp(filename, 'respLocked_erp_100_spatialPatterns'))
        timeline =  [-4 : 0.01 : 0];
    elseif  (strcmp(filename, 'erp_100_spatialPatterns'))
        timeline = [-0.45 : 0.01 : 4.49];
    elseif (strcmp(filename, 'probeLocked_erp_100_longEpoch_spatialPatterns'))
        timeline = [-4.5 : 0.01 : 0.5];
    end
    
    if (strcmp(filename, 'erp_100_spatialPatterns')) | (strcmp(filename, 'respLocked_erp_100_spatialPatterns')) | (strcmp(filename, 'probeLocked_erp_100_longEpoch_spatialPatterns'))
        for bini = 1 : length(timebins)
            ind1  = nearest(timeline,timebins(bini, 1));
            ind2  = nearest(timeline, timebins(bini, 2));
            ind2 = ind2-1;
            
            data_tmp{subi}(bini, :) =  mean(data{subi}(:, ind1:ind2), 2);
        end
        
        data{subi} = data_tmp{subi};
        
        if normalization
            tmp1 = data{subi}(:);
            tmp1 = normalize(tmp1);
            data{subi} = reshape(tmp1, [size(data{subi}, 1), size(data{subi}, 2)]);
        end
    end
    
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

% %Concatenate to be able to apply colormap across all electrodes
% X_pos = [];
% Y_pos = [];
% Z_pos = [];
% dat2plot = [];
% 
% for subi = 1 : length(subnips)
%     display(subnips{subi});
%     if ~isempty(channels{subi}.chanpos)
%         tmp_X = channels{subi}.chanpos(:, 1);
%         tmp_Y = channels{subi}.chanpos(:, 2);
%         tmp_Z = channels{subi}.chanpos(:, 3);
% 
%         tmp_data = data{subi}(ind{subi})';
%     else
%         tmp_X = nan;
%         tmp_Y = nan;
%         tmp_Z = nan;
% 
%         tmp_data = nan;
%     end
% 
%     X_pos = [X_pos; tmp_X];
%     Y_pos = [Y_pos; tmp_Y];
%     Z_pos = [Z_pos; tmp_Z];
% 
%     dat2plot = [dat2plot; tmp_data]; %1 row with all of the decoding scores
% 
%     clear ('tmp_X', 'tmp_Y', 'tmp_Z', 'tmp_data');
% end
%my_alphas = dat2plot < c_min;

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
    
    
    %my_alphas{toi_i} = dat2plot{toi_i} < c_min;
end

%% Zscore data to be comparable
dat2plot_tmp = cell2mat(dat2plot);

%Exclude any below-chance decoding from z-score procedure
dat2plot_tmp(dat2plot_tmp <= .5) = nan;

%Reshape so that z-score is computed across all channels/timebins
dat2plot_zscore = dat2plot_tmp(:);
dat2plot_zscore = normalize(dat2plot_zscore);

dat2plot_zscore = reshape(dat2plot_zscore, [size(dat2plot_tmp, 1), size(dat2plot_tmp, 2)]);

%Convert back to cell
dat2plot_zscore_cell = cell(1, size(dat2plot_zscore, 2));

for ii =  1 : size(dat2plot_zscore_cell, 2)
    dat2plot_zscore_cell{1, ii} = dat2plot_zscore(:, ii);
end

%% Plot raw pattern scores
%Alphas
for toi_i = 1 : size(data{1}, 1)
    my_alphas{toi_i} = isnan(dat2plot{toi_i});
end

%Colormap
if strcmp(fmethod, 'respLocked_erp_100')
    if strcmp(decCond, 'buttonPress_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'probe_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'probeID_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'load_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'indItems_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'itemPos_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'cue_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    end
elseif (strcmp(fmethod, 'erp_100')) | (strcmp(fmethod, 'probeLocked_erp_100_longEpoch'))
    if strcmp(decCond, 'buttonPress_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'probe_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'probeID_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'load_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'indItems_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'itemPos_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    elseif strcmp(decCond, 'cue_diag')
        c_min = min(min([dat2plot{:}]));
        c_max = max(max([dat2plot{:}]));
    end
end

if strcmp(fmethod, 'respLocked_erp_100')
    fig_inds = [1:10; 11:20; 21:30; 31:40];
elseif strcmp(fmethod, 'erp_100') | strcmp(fmethod, 'probeLocked_erp_100_longEpoch')
    fig_inds = [1:10; 11:20; 21:30; 31:40; 41:50];
end

for figi = 1 : size(fig_inds, 1)
    figure;
    
    for toi_i = fig_inds(figi, :)  
        
        if figi == 1
            subplot(2, 5, toi_i);
        else
            subplot(2, 5, toi_i-(figi-1)*10);
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

        %my_handle = plot3(channels{subi}.chanpos(:, 1), channels{subi}.chanpos(:, 2), channels{subi}.chanpos(:, 3), 'o', 'MarkerFaceColor', my_colors(subi, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'DisplayName', subnips{subi});
        scatter3(X_pos{toi_i}, Y_pos{toi_i}, Z_pos{toi_i}, 3, 'MarkerEdgeColor', [105, 105, 105] ./255); %stupid way to get black outline around electrodes
        scatter3(X_pos{toi_i}(my_alphas{toi_i}), Y_pos{toi_i}(my_alphas{toi_i}), Z_pos{toi_i}(my_alphas{toi_i}), 3, dat2plot{toi_i}(my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 0); %stupid way to adjust transparency of individual electrodes
        my_handle = scatter3(X_pos{toi_i}(~my_alphas{toi_i}), Y_pos{toi_i}(~my_alphas{toi_i}), Z_pos{toi_i}(~my_alphas{toi_i}), 3, dat2plot{toi_i}(~my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 1);

        %colorbar;

        %hold off

        title(num2str(timebins(toi_i, 1)), 'FontName', 'Arial', 'FontWeight', 'normal', 'FontSize', 8);
        
        if strcmp(fmethod, 'erp_100') & toi_i == 47
            break;
        end
    end
    
    %Save
    %filename = ['/media/darinka/Data0/iEEG/Results/Figures/Group/DecodingPerChannel_Final' hemi '_' viewside];
    savename = ['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/Figures/' decCond '_' filename '_DecodingPerChannel_' hemi '_' viewside '_' num2str(figi) '.pdf'];
    printfig(gcf, [0, 0, 15 10], savename);
    
    %close light;
    close all;
end

%% Plot raw AUC scores
%Alphas
for toi_i = 1 : size(data{1}, 1)
    my_alphas{toi_i} = dat2plot{toi_i} <= .5;
end

%Colormap
if strcmp(fmethod, 'respLocked_erp_100')
    if strcmp(decCond, 'buttonPress_diag')
        c_min = .5;
        c_max = .7;
    elseif strcmp(decCond, 'probe_diag')
        c_min = .5;
        c_max = .7;
    elseif strcmp(decCond, 'probeID_diag')
        c_min = .5;
        c_max = .61;
    elseif strcmp(decCond, 'load_diag')
        c_min = .5;
        c_max = .65;
    elseif strcmp(decCond, 'indItems_diag')
        c_min = .5;
        c_max = .59;
    elseif strcmp(decCond, 'itemPos_diag')
        c_min = .5;
        c_max = .6;
    elseif strcmp(decCond, 'cue_diag')
        c_min = .5;
        c_max = .7;
    end
elseif strcmp(fmethod, 'erp_100')
    if strcmp(decCond, 'buttonPress_diag')
        c_min = .5;
        c_max = 69;
    elseif strcmp(decCond, 'probe_diag')
        c_min = .5;
        c_max = .69;
    elseif strcmp(decCond, 'probeID_diag')
        c_min = .5;
        c_max = .64;
    elseif strcmp(decCond, 'load_diag')
        c_min = .5;
        c_max = .8;
    elseif strcmp(decCond, 'indItems_diag')
        c_min = .5;
        c_max = .6;
    elseif strcmp(decCond, 'itemPos_diag')
        c_min = .5;
        c_max = .7;
    elseif strcmp(decCond, 'cue_diag')
        c_min = .5;
        c_max = .68;
    end
end

if strcmp(fmethod, 'respLocked_erp_100')
    fig_inds = [1:10; 11:20; 21:30; 31:40];
elseif strcmp(fmethod, 'erp_100')
    fig_inds = [1:10; 11:20; 21:30; 31:40; 41:50];
end

for figi = 1 : size(fig_inds, 1)
    figure;
    
    for toi_i = fig_inds(figi, :)  
        
        if figi == 1
            subplot(2, 5, toi_i);
        else
            subplot(2, 5, toi_i-(figi-1)*10);
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

        %my_handle = plot3(channels{subi}.chanpos(:, 1), channels{subi}.chanpos(:, 2), channels{subi}.chanpos(:, 3), 'o', 'MarkerFaceColor', my_colors(subi, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'DisplayName', subnips{subi});
        scatter3(X_pos{toi_i}, Y_pos{toi_i}, Z_pos{toi_i}, 3, 'MarkerEdgeColor', [105, 105, 105] ./255); %stupid way to get black outline around electrodes
        scatter3(X_pos{toi_i}(my_alphas{toi_i}), Y_pos{toi_i}(my_alphas{toi_i}), Z_pos{toi_i}(my_alphas{toi_i}), 3, dat2plot{toi_i}(my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 0); %stupid way to adjust transparency of individual electrodes
        my_handle = scatter3(X_pos{toi_i}(~my_alphas{toi_i}), Y_pos{toi_i}(~my_alphas{toi_i}), Z_pos{toi_i}(~my_alphas{toi_i}), 3, dat2plot{toi_i}(~my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 1);

        %colorbar;

        %hold off

        title(num2str(timebins(toi_i, 1)), 'FontName', 'Arial', 'FontWeight', 'normal', 'FontSize', 8);
        
        if strcmp(fmethod, 'erp_100') & toi_i == 47
            break;
        end
    end
    
    %Save
    %filename = ['/media/darinka/Data0/iEEG/Results/Figures/Group/DecodingPerChannel_Final' hemi '_' viewside];
    savename = ['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/Figures/' decCond '_' filename '_DecodingPerChannel_' hemi '_' viewside '_' num2str(figi) '.pdf'];
    printfig(gcf, [0, 0, 15 10], savename);
    
    %close light;
    close all;
end
%% Plot z-scored data
%Alphas
for toi_i = 1 : size(data{1}, 1)
    my_alphas{toi_i} = isnan(dat2plot_zscore_cell{toi_i});
end

if strcmp(fmethod, 'respLocked_erp_100')
    fig_inds = [1:10; 11:20; 21:30; 31:40];
    
    if strcmp(decCond, 'buttonPress_diag')
        %Colormap
        %c_min = 4;
        c_max = 10;
    elseif strcmp(decCond, 'probe_diag')
        c_max = 5;
    elseif strcmp(decCond, 'probeID_diag')
        c_max = 5;
    elseif strcmp(decCond, 'load_diag')
        c_max = 5;
    elseif strcmp(decCond, 'indItems_diag')
        c_max = 7;
    elseif strcmp(decCond, 'itemPos_diag')
        c_max = 5.9;
    elseif strcmp(decCond, 'cue_diag')
        c_max = 6;
    end
elseif strcmp(fmethod, 'erp_100')
        fig_inds = [1:10; 11:20; 21:30; 31:40; 41:50];
    
    if strcmp(decCond, 'buttonPress_diag')
        %Colormap
        %c_min = 4;
        c_max = 5.7;
    elseif strcmp(decCond, 'probe_diag')
        c_max = 5.6;
    elseif strcmp(decCond, 'probeID_diag')
        c_max = 7.4;
    elseif strcmp(decCond, 'load_diag')
        c_max = 9;
    elseif strcmp(decCond, 'indItems_diag')
        c_max = 7;
    elseif strcmp(decCond, 'itemPos_diag')
        c_max = 10;
    elseif strcmp(decCond, 'cue_diag')
        c_max = 5;
    end
end

for figi = 1 : size(fig_inds, 1)
    figure;
    
    for toi_i = fig_inds(figi, :)
        
        
        if figi == 1
            subplot(2, 5, toi_i);
        else
            subplot(2, 5, toi_i-(figi-1)*10);
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
        light('Position', view_position);

        %my_handle = plot3(channels{subi}.chanpos(:, 1), channels{subi}.chanpos(:, 2), channels{subi}.chanpos(:, 3), 'o', 'MarkerFaceColor', my_colors(subi, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'DisplayName', subnips{subi});
        scatter3(X_pos{toi_i}, Y_pos{toi_i}, Z_pos{toi_i}, 3, 'MarkerEdgeColor', [105, 105, 105] ./255); %stupid way to get black outline around electrodes
        scatter3(X_pos{toi_i}(my_alphas{toi_i}), Y_pos{toi_i}(my_alphas{toi_i}), Z_pos{toi_i}(my_alphas{toi_i}), 3, dat2plot_zscore_cell{toi_i}(my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 0); %stupid way to adjust transparency of individual electrodes
        my_handle = scatter3(X_pos{toi_i}(~my_alphas{toi_i}), Y_pos{toi_i}(~my_alphas{toi_i}), Z_pos{toi_i}(~my_alphas{toi_i}), 3, dat2plot_zscore_cell{toi_i}(~my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 1);

        %colorbar;

        %hold off

        title(num2str(timebins(toi_i, 1)), 'FontName', 'Arial', 'FontWeight', 'normal', 'FontSize', 8);
        
        if strcmp(fmethod, 'erp_100') & toi_i == 47
            break;
        end
    end
    
    %Save
    %filename = ['/media/darinka/Data0/iEEG/Results/Figures/Group/DecodingPerChannel_Final' hemi '_' viewside];
    savename = ['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/Figures/' decCond '_' filename '_DecodingPerChannel_' hemi '_' viewside '_' num2str(figi) '_zscore.pdf'];
    printfig(gcf, [0, 0, 15 10], savename);
    
    close all;
end

%% Plot peak decoding only (i.e., the 100 ms time bin in which it fell)

%Define new c_min, c_max
c_min = 0.55;
c_max = 0.6;

% Define new alpha
for toi_i = 1 : size(data{1}, 1)
    my_alphas{toi_i} = dat2plot{toi_i} <= 0.5;
end

%Retrieve toi_i
toi_i = peakDecoding;

figure;

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
light('Position', view_position);

%my_handle = plot3(channels{subi}.chanpos(:, 1), channels{subi}.chanpos(:, 2), channels{subi}.chanpos(:, 3), 'o', 'MarkerFaceColor', my_colors(subi, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'DisplayName', subnips{subi});
scatter3(X_pos{toi_i}, Y_pos{toi_i}, Z_pos{toi_i}, 15, 'MarkerEdgeColor', 'k'); %stupid way to get black outline around electrodes
scatter3(X_pos{toi_i}(my_alphas{toi_i}), Y_pos{toi_i}(my_alphas{toi_i}), Z_pos{toi_i}(my_alphas{toi_i}), 15, dat2plot_zscore_cell{toi_i}(my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 0); %stupid way to adjust transparency of individual electrodes
my_handle = scatter3(X_pos{toi_i}(~my_alphas{toi_i}), Y_pos{toi_i}(~my_alphas{toi_i}), Z_pos{toi_i}(~my_alphas{toi_i}), 15, dat2plot_zscore_cell{toi_i}(~my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 1);

colorbar;

hold off

title(num2str(timebins(toi_i, 1)));


%% Plot mean of time bins

%Define new c_min, c_max
c_min = 0.55;
c_max = 0.6;

% Define new alpha
for toi_i = 1 : size(data{1}, 1)
    my_alphas{toi_i} = dat2plot{toi_i} <= 0.5;
end

%Retrieve toi_i
toi_i = peakDecoding;

figure;

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
light('Position', view_position);

%my_handle = plot3(channels{subi}.chanpos(:, 1), channels{subi}.chanpos(:, 2), channels{subi}.chanpos(:, 3), 'o', 'MarkerFaceColor', my_colors(subi, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'DisplayName', subnips{subi});
scatter3(X_pos{toi_i}, Y_pos{toi_i}, Z_pos{toi_i}, 15, 'MarkerEdgeColor', 'k'); %stupid way to get black outline around electrodes
scatter3(X_pos{toi_i}(my_alphas{toi_i}), Y_pos{toi_i}(my_alphas{toi_i}), Z_pos{toi_i}(my_alphas{toi_i}), 15, dat2plot_zscore_cell{toi_i}(my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 0); %stupid way to adjust transparency of individual electrodes
my_handle = scatter3(X_pos{toi_i}(~my_alphas{toi_i}), Y_pos{toi_i}(~my_alphas{toi_i}), Z_pos{toi_i}(~my_alphas{toi_i}), 15, dat2plot_zscore_cell{toi_i}(~my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 1);

colorbar;

hold off

title(num2str(timebins(toi_i, 1)));
