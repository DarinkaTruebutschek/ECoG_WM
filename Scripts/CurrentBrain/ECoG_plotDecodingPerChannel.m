%This script projects the results of the channel-wise item decoding onto
%standard mni brain.
%Project: ECoG_WM
%Author: D.T.
%Date: 03 February 2020

clear all;
close all;
clc;

%% Specify important variables

subnips = {'MKL', 'EG_I', 'HS', 'MG', 'KR', 'WS', 'KJ_I', 'LJ', 'AS', 'SB', 'AP'};

hemi = 'right';
viewside = 'lateral';

score_type = 'bl';
filename = 'erp_TimDim_timeBin_500_stepSize_500';

%For plotting
my_colors = cbrewer('seq', 'YlOrRd', 12);
%first_col = [0, 0, 0];
%remaining_col = cbrewer('seq', 'YlOrRd', 12);
%my_colors = [first_col; remaining_col];

%my_alphas = [0; ones(12, 1)]; %to add transparency to colormap

%my_colors = [my_colors, my_alphas];

c_min = .505;
c_max = .525;

%% Import necessary paths
ECoG_setPath;

%% Project all of the subjects' individual electrodes into standard mni space
for subi = 1 : length(subnips)
    
    display(['Loading data for subject ', subnips{subi}]);
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']); %load preprocessed data including the necessary channel information
    tmp{subi} = load(['/media/darinka/Data0/iEEG/Results/Decoding/' filename '/forMatlab/' subnips{subi} '_erp_timDim_indItems_diag_' filename '_averageDecodingPerChannel_' score_type '.mat']);
    
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
        channelSelection{subi} = {channels_left{subi}};
    elseif strcmp(hemi, 'right')
        pial_file = 'pial_right.mat';
        channelSelection{subi} = {channels_right{subi}};
    end
    
    %Extract infos about channels
    [channels{subi}, ind{subi}] = ECoG_splitElectrodes(reref.elec_mni_frv, channelSelection{subi}{1});
end

%Concatenate to be able to apply colormap across all electrodes
X_pos = [];
Y_pos = [];
Z_pos = [];
dat2plot = [];

for subi = 1 : length(subnips)
    display(subnips{subi});
    if ~isempty(channels{subi}.chanpos)
       tmp_X = channels{subi}.chanpos(:, 1);
       tmp_Y = channels{subi}.chanpos(:, 2);
       tmp_Z = channels{subi}.chanpos(:, 3);
       
       tmp_data = data{subi}(ind{subi})';
    else
        tmp_X = nan;
        tmp_Y = nan;
        tmp_Z = nan;
        
        tmp_data = nan;
    end
    
    X_pos = [X_pos; tmp_X];
    Y_pos = [Y_pos; tmp_Y];
    Z_pos = [Z_pos; tmp_Z];
    
    dat2plot= [dat2plot; tmp_data];
    
    clear ('tmp_X', 'tmp_Y', 'tmp_Z', 'tmp_data');
end

my_alphas = dat2plot < c_min;
%% Plot
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
scatter3(X_pos, Y_pos, Z_pos, 40, 'MarkerEdgeColor', 'k'); %stupid way to get black outline around electrodes
scatter3(X_pos(my_alphas), Y_pos(my_alphas), Z_pos(my_alphas), 40, dat2plot(my_alphas), 'filled', 'MarkerFaceAlpha', 0); %stupid way to adjust transparency of individual electrodes
my_handle = scatter3(X_pos(~my_alphas), Y_pos(~my_alphas), Z_pos(~my_alphas), 40, dat2plot(~my_alphas), 'filled', 'MarkerFaceAlpha', 1);

colorbar;

hold off

title(score_type);

%Save
filename = ['/media/darinka/Data0/iEEG/Results/Figures/Group/DecodingPerChannel_' score_type '_' hemi '_' viewside];
printfig(gcf, [0, 0, 25 12.5], filename);


