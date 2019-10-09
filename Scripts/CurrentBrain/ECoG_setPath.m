%This script defines the paths necessary for the analyses.
%Project: ECoG_WM
%Author: D.T.
%Date: 23 May 2019

%%
behavior_path = '/media/darinka/Data0/iEEG/Results/Behavior/';
dat_path = '/media/darinka/Data0/iEEG/Results/RawData/';
res_path = '/media/darinka/Data0/iEEG/Results/Data/';
mri_path = '/media/darinka/Data0/iEEG/Results/MRI/Pre_Op/';
ct_path = '/media/darinka/Data0/iEEG/Results/CT/Post_Op/';
script_path = '/media/darinka/Data0/iEEG/ECoG_WM/Scripts/';
behavior_script_path = '/media/darinka/Data0/iEEG/ECoG_WM/Scripts/CurrentBehavior/';
brain_script_path = '/media/darinka/Data0/iEEG/ECoG_WM/Scripts/CurrentBrain/';
toolbox_path = '/media/darinka/Data0/iEEG/ECoG_WM/Scripts/Toolboxes/';
fieldtrip_path = '/usr/local/Fieldtrip';

%%
addpath fieldtrip-20190329;
ft_defaults;
