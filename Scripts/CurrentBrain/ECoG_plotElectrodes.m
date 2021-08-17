%This script overlays the actual electrode positions first onto the
%subject's individual brain, and then the group electrodes onto the mni
%brain.
%Project: ECoG_WM
%Author: D.T.
%Date: 23 May 2019

clear all;
close all;
clc;

%% Specify important variables

%subnips = {'MG', 'EG_I', 'HL', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};
sublabels = {'Sub1', 'Sub2', 'Sub3', 'Sub4', 'Sub5', 'Sub6', 'Sub7', 'Sub8', 'Sub9', 'Sub10', 'Sub11'};

%channelSelection = {{'CP*', 'FL*', 'TLS*', 'TLI*', 'CA*', 'HIP*', 'TBP*', 'OB*'}}';
hemi = 'left';
viewside = 'lateral';

%For plotting
%my_colors = cbrewer('div', 'Spectral', 12); %use this when plotting single subjects
my_colors = cbrewer('qual', 'Paired', length(subnips));

%% Import necessary paths
ECoG_setPath;

%% Load necessary data and plot individual subjects first
for subi = 1 : length(subnips)
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_temporal_reref.mat']); %load preprocessed data including the necessary channel information
    fsmri_acpc = ft_read_mri([mri_path subnips{subi} '/freesurfer/mri/T1.mgz']); %read freesurfer-based mri
    
    %Select channels
    [channels_left, channels_right] = ECoG_subjInfo(subnips{subi}, 'all');
    
    if strcmp(hemi, 'left')
        pial_file = 'lh.pial';
        channelSelection = {channels_left};
    elseif strcmp(hemi, 'right')
        pial_file = 'rh.pial';
        channelSelection = {channels_right};
    end
    
    %Extract infos about channels
    channels = ECoG_splitElectrodes(reref.elec, channelSelection{1});
    
    %Plot
    figure;
    pial = ft_read_headshape([mri_path subnips{1} '/freesurfer/surf/' pial_file]);  
    
    ft_plot_mesh(pial, 'facecolor', [.9, .9, .9], 'facealpha', 0.3);
    ft_plot_sens(channels, 'elecshape', 'sphere', 'facecolor', my_colors(1, :), 'facealpha', .5);
    view([-90 20]); 
    material dull; 
    lighting gouraud; 
    camlight;
    
    pause;
end

clear ('channels', 'channel_left', 'channels_right', 'channelSelection');
%% Project all of the subjects' individual electrodes into standard mni space
for subi = 1 : length(subnips)
    
    display(['Loading data for subject ', subnips{subi}]);
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_temporal_reref.mat']); %load preprocessed data including the necessary channel information
    reref = reref_anat;
    
    %Select channels
    [channels_left{subi}, channels_right{subi}] = ECoG_subjInfo(subnips{subi}, 'all');
    
    %This used to work when I wanted to show all electrodes
    if strcmp(hemi, 'left')
        pial_file = 'pial_left.mat';
        channelSelection{subi} = {channels_left{subi}};
    elseif strcmp(hemi, 'right')
        pial_file = 'pial_right.mat';
        channelSelection{subi} = {channels_right{subi}};
    end
    
%     %For subset of electrodes
%     if strcmp(hemi, 'left')
%         pial_file = 'pial_left.mat';
%         channelSelec
%     end
    
    %Extract infos about channels
    channels{subi} = ECoG_splitElectrodes(reref.elec_mni_frv, channelSelection{subi}{1});
end

%Plot
figure;

hold on
pial = ft_read_headshape(['/usr/local/Fieldtrip/fieldtrip-20190329/template/anatomy/surface_' pial_file]);  
%h = ft_plot_mesh(pial, 'facecolor', [.15, .15, .15], 'facealpha', .6);
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

for subi = 1 : length(subnips)
    display(subnips{subi});
    
%     %Quick fix to be able to plot subjects with less than three channels
%     if ~isempty(channels{subi}.chanpos) && size(channels{subi}.chanpos, 1) < 3
%         
%         display('Adding dummy electrode for plotting purposes only ... ');
%         
%         %Update matrix
%         channels{subi}.chanpos(end+1, :) = channels{subi}.chanpos(end, :)+diff(channels{subi}.chanpos);
%         channels{subi}.chantype{end+1} = 'eeg';
%         channels{subi}.chanunit{end+1} = 'V';
%         channels{subi}.elecpos(end+1, :) = channels{subi}.elecpos(end, :)+diff(channels{subi}.elecpos);
%         channels{subi}.label{end+1} = 'dummy_electrode';
%         
%         channels{subi}.tra = eye(size(channels{subi}.label, 1));
%         
%         %Update color information
%         color_tmp = my_colors(subi, :);
%         color_tmp = repmat(color_tmp, size(channels{subi}.tra, 1)-1, 1);
%         color_tmp(end+1, :) = [.9, .9, .9]; %same as brain
%         
%         color_edge = ones(1, 3);
%         color_edge = repmat(color_edge, size(channels{subi}.tra, 1)-1, 1);
%         color_edge(end+1, :) = color_tmp(end, :);
%         
%         %my_handle = ft_plot_sens(channels{subi}, 'elecshape', 'point', 'elecsize', 30, 'facecolor', color_tmp, 'facealpha', 1);
%         my_handle= plot3(channels{subi}.chanpos(:, 1), channels{subi}.chanpos(:, 2), channels{subi}.chanpos(:, 3), 'o', 'MarkerFaceColor', color_tmp(subi, :), 'MarkerEdgeColor', color_edge, 'MarkerSize', 6, 'DisplayName', subnips{subi});
%     end
    
    if ~isempty(channels{subi}.chanpos)
        my_handle = plot3(channels{subi}.chanpos(:, 1), channels{subi}.chanpos(:, 2), channels{subi}.chanpos(:, 3), 'o', 'MarkerFaceColor', my_colors(subi, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'DisplayName', subnips{subi});
    else
        plot3(nan, nan, nan, 'o', 'MarkerFaceColor', my_colors(subi, :), 'MarkerEdgeColor', 'k', 'MarkerSize', 6, 'DisplayName', subnips{subi});
    end
end

legend(sublabels{:}, 'Location', 'best', 'NumColumns', 6);
legend('boxon');

hold off

%Save
filename = ['/media/darinka/Data0/iEEG/Results/Figures/Group/Final_ElectrodeCov_temporal_' hemi '_' viewside];
printfig(gcf, [0, 0, 25 12.5], filename);


