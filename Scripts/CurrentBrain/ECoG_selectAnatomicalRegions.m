%This script selects only those electrodes within a given anatomical
%region.
%Project: ECoG_WM
%Author: D.T.
%Date: 14 June 2021

clear all;
close all;
clc;

%% Specify important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};

area = 'temporal'; %also: 'temporal', 'posterior'

%% Import necessary paths
ECoG_setPath;

%% Loop over subjects
for subi = 1 : length(subnips)
   
    display(['Extracting channels for subject: ', subnips{subi}]);
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_reref.mat']); %load preprocessed data including the necessary channel information
    
    %Get names of channels belonging to a certain anatomical area
    chanIncluded = ECoG_getAnatomicalChannel(area, subnips{subi});
    chanIncluded = chanIncluded';
    
    chanInds = [];
    for chani = 1 : length(chanIncluded)
        if isempty(chanIncluded{chani})
            chanInds(chani) = 0;
        else
            chanInds(chani) = 1;
        end
    end
    chanInds = chanInds';
    chanInds = logical(chanInds);
    
    %Select exactly that data
    cfg = [];
    cfg.channel = chanIncluded(~cellfun(@isempty, chanIncluded));
    reref_anat = ft_selectdata(cfg, reref);
    
    %Change relevant electrode info
    reref_anat.elec.chanpos = reref_anat.elec.chanpos(chanInds, :);
    reref_anat.elec.chantype = reref_anat.elec.chantype(chanInds);
    reref_anat.elec.chanunit = reref_anat.elec.chanunit(chanInds);
    reref_anat.elec.label = reref_anat.elec.label(chanInds);
    reref_anat.elec.tra = reref_anat.elec.tra(chanInds', :);
    
    reref_anat.elec_mni_frv.chanpos = reref_anat.elec_mni_frv.chanpos(chanInds, :);
    reref_anat.elec_mni_frv.chantype = reref_anat.elec_mni_frv.chantype(chanInds);
    reref_anat.elec_mni_frv.chanunit = reref_anat.elec_mni_frv.chanunit(chanInds);
    reref_anat.elec_mni_frv.label = reref_anat.elec_mni_frv.label(chanInds);
    reref_anat.elec_mni_frv.tra = reref_anat.elec_mni_frv.tra(chanInds', :);
    
    display(reref_anat.elec.label);
    
    %Save
    save([res_path subnips{subi} '/' subnips{subi} '_' area '_reref.mat'], 'reref_anat', '-v7.3');
    
    clear('chanIncluded', 'reref_anat');
end



