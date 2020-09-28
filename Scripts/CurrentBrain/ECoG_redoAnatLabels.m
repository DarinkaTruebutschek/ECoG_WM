%Purpose: This script redoes the anatomical labeling of the electrodes based only on
%the electrodes inlcuded within a given subject (i.e., after bipolar
%referencing)
%Project: ECoG_WM
%Author: Darinka Truebutschek
%Date: 28 September 2020

clear all;
close all;
clc;

%% Path
ECoG_setPath;

%% Define important variables
%subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips
subnips = {'AP'}; %included subnips

%% Loop over subjects
for subi = 1 : length(subnips)
    
    load([res_path subnips{1} '/' subnips{1} '_reref.mat']);
    
    xldir = [script_path '20130227_xlwrite'];
    fsdir = [mri_path subnips{subi} '/freesurfer'];

%     M.xldir = xldir;
%     M.fsdir = fsdir;
%     M.elec_nat = reref.elec;
%     M.elec_mni = reref.elec_mni_frv;

    %Extract elec files and change it simply so that coordinates are
    %correct
    elec = reref.elec;
    elec.elecpos = reref.elec.chanpos;
    
    elec_mni_frv = reref.elec_mni_frv;
    elec_mni_frv.elecpos = reref.elec_mni_frv.chanpos;

    e_pos = ['/media/darinka/Data0/iEEG/Results/Electrodes/' subnips{1} '/' subnips{1} '_elec_pos_final.xlsx'];
    table = generate_electable(e_pos, 'xldir', xldir, 'fsdir', fsdir, 'elec_nat', elec, 'elec_mni', elec_mni_frv);
    
    clear('table');
end