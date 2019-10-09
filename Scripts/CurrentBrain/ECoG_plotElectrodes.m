%This script overlays the actual electrode positions onto the subject's individual brain.
%Project: ECoG_WM
%Author: D.T.
%Date: 23 May 2019

clear all;
close all;
clc;

%% Specify important variables

subnips = {'MG'};

channelSelection = {{'CP*', 'FL*', 'TLS*', 'TLI*', 'CA*', 'HIP*', 'TBP*', 'OB*'}}';
pial_file = 'rh.pial';

%For plotting
my_colors = cbrewer('div', 'Spectral', 12);

%% Import necessary paths
ECoG_setPath;

%% Load necessary data and plot
for subi = 1 : length(subnips)
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']); %load preprocessed data including the necessary channel information
    fsmri_acpc = ft_read_mri([mri_path subnips{subi} '/freesurfer/mri/T1.mgz']); %read freesurfer-based mri
    
    %Extract infos about channels
    channels = ECoG_splitElectrodes(reref.elec, channelSelection{subi});
    
    %Plot
    figure;
    pial = ft_read_headshape([mri_path subnips{1} '/freesurfer/surf/' pial_file]);  
    
    ft_plot_mesh(pial, 'facecolor', [.9, .9, .9], 'facealpha', 0.3);
    ft_plot_sens(channels, 'elecshape', 'sphere', 'facecolor', my_colors(1, :), 'facealpha', .5);
    view([-90 20]); 
    material dull; 
    lighting gouraud; 
    camlight;
end


