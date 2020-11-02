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

score_type = 'postItem';
decCond = 'cue_diag';
%filename = 'erp_TimDim_timeBin_500_stepSize_500_meanSubtraction';
filename = 'erp_100_TimDim_allTimeBins_meanSubtraction';

%For plotting
my_colors = cbrewer('seq', 'YlOrRd', 12);
if ~strcmp(decCond, 'buttonPress_diag') && ~strcmp(decCond, 'probe_diag')
    timebins = {'Baseline', 'Cue', 'Delay 1', 'Items', 'Del2'};
else
    timebins = {'-4.0s to -3.0s', '-3.0s to -2.0s', '-2.0s to -1.0s', '-1.0s to -0.5s', '-0.5s to 0s'};
end

%first_col = [0, 0, 0];
%remaining_col = cbrewer('seq', 'YlOrRd', 12);
%my_colors = [first_col; remaining_col];

%my_alphas = [0; ones(12, 1)]; %to add transparency to colormap

%my_colors = [my_colors, my_alphas];

%c_min = .505;
%c_max = .525;

c_min = .55;
c_max = .7;

%% Import necessary paths
ECoG_setPath;

%% Project all of the subjects' individual electrodes into standard mni space
for subi = 1 : length(subnips)
    
    display(['Loading data for subject ', subnips{subi}]);
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']); %load preprocessed data including the necessary channel information
    %tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_indItems_diag_' filename '_averageDecodingPerChannel_' score_type '.mat']);
    tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_' decCond '_' filename '_scores.mat']);
    data{subi} = tmp{subi}.data;
    
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
    
    my_alphas{toi_i} = dat2plot{toi_i} < c_min;
end

%% Plot
for toi_i = 1 : size(data{1}, 1)
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
    scatter3(X_pos{toi_i}, Y_pos{toi_i}, Z_pos{toi_i}, 40, 'MarkerEdgeColor', 'k'); %stupid way to get black outline around electrodes
    scatter3(X_pos{toi_i}(my_alphas{toi_i}), Y_pos{toi_i}(my_alphas{toi_i}), Z_pos{toi_i}(my_alphas{toi_i}), 40, dat2plot{toi_i}(my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 0); %stupid way to adjust transparency of individual electrodes
    my_handle = scatter3(X_pos{toi_i}(~my_alphas{toi_i}), Y_pos{toi_i}(~my_alphas{toi_i}), Z_pos{toi_i}(~my_alphas{toi_i}), 40, dat2plot{toi_i}(~my_alphas{toi_i}), 'filled', 'MarkerFaceAlpha', 1);

    colorbar;

    hold off

    title([timebins{toi_i} ': ' decCond]);

    %Save
    %filename = ['/media/darinka/Data0/iEEG/Results/Figures/Group/DecodingPerChannel_' score_type '_' hemi '_' viewside];
    savename = ['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/Figures/Group_' decCond '_' filename '_DecodingPerChannel_toi_' timebins{toi_i} '_' hemi '_' viewside '.tiff'];
    printfig(gcf, [0, 0, 25 12.5], savename);
end


