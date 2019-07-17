%This script runs the entire preprocessing pipeline for the ECoG dataset.
%Project: ECoG_WM
%Author: D.T.
%Date: 29 April 2019

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'MKL','EG_I','HS','MG','KR','WS','KJ_I','LJ','AS','SB','HL','AP'}; %all subjects included in analysis
subnips = {'AP'};

%Paths to anatomical/functional data
if strcmp(subnips, 'MKL')
    pre_mri_file = [mri_path subnips{1} '/co20160914_091845t1mprsagp2isos006a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/20160914_13332001CCTXCAREs005a002A_flipped.nii.gz'];
    raw_data_file{1} = [dat_path subnips{1} '/KLein-Mara-I.EDF'];
    raw_data_file{2} = [dat_path subnips{1} '/Klein-Mara-II.EDF'];
elseif strcmp(subnips, 'EG_I')
    pre_mri_file = [mri_path subnips{1} '/co20180109_091436t1mprsagp2isos004a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/20180109_13140101CCTXCAREs003a002.nii.gz']; 
    raw_data_file{1} = [dat_path subnips{1} '/Sess1_OA8889B6.EDF'];
    raw_data_file{2} = [dat_path subnips{1} '/Sess2_OA8889EI.EDF'];
elseif strcmp(subnips, 'HS')
    pre_mri_file = [mri_path subnips{1} '/co20170411_085246t1mprsagp2isos004a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/o20170411_15215501CCTXCAREs003a002.nii.gz']; %
    %post_ct_file = [ct_path subnips{1}
    %'/20170411_15215501CCTXCAREs003a002.nii.gz']; %%fusing with
    %pre-freesurfer MRI doesn't really seem to work with this one (ctf_old)
    raw_data_file{1} = [dat_path subnips{1} '/SCHACHT.H.20170414..10.43Uhr.EDF'];
    raw_data_file{2} = [dat_path subnips{1} '/SCHACHT.H..2017.04.14...13.53Uhr.EDF'];
elseif strcmp(subnips, 'MG')
    pre_mri_file = [mri_path subnips{1} '/co20170404_081552t1mprsagp2iso09320s006a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/o20171122_09255601CCTXCAREs003a002.nii.gz']; 
    %post_ct_file = [ct_path subnips{1} '/MG_rawCT_rawMRI.nii.gz']; %first had to align raw, oriented CT with raw, oriented (but not cut) MRI to be able to align those scans later on
    raw_data_file{1} = [dat_path subnips{1} '/Sess1_OA8888G5.EDF'];
    raw_data_file{2} = [dat_path subnips{1} '/Sess2_OA8888IS.EDF'];
    raw_data_file{3} = [dat_path subnips{1} '/Sess3_OA8888KJ.EDF'];
elseif strcmp(subnips, 'KR')
    pre_mri_file = [mri_path subnips{1} '/co20170614_091821t1mprsagp2isos005a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/o20170614_13134901CCTXCAREs003a002.nii.gz']; 
    raw_data_file{1} = [dat_path subnips{1} '/2017-06-20T09-18-11.834ZKR1.json'];
elseif strcmp(subnips, 'WS')
    pre_mri_file = [mri_path subnips{1} '/SE000004_t1_mpr_sag_iso_20160722081835_5.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/SE000005_01_CCT_XCARE_20171206132517_6.nii.gz']; 
    raw_data_file{1} = [dat_path subnips{1} '/Sess1_OA8888RN.EDF'];
    raw_data_file{2} = [dat_path subnips{1} '/Sess2_OA8888TP.EDF'];
elseif strcmp(subnips, 'KJ_I')
    pre_mri_file = [mri_path subnips{1} '/co20160129_081104t1mprsagp2iso09320s006a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/20180207_11122901CCTXCARESAFIREs005a002A.nii.gz']; 
    raw_data_file{1} = [dat_path subnips{1} '/Sess1_OA8889WM.EDF'];
    raw_data_file{2} = [dat_path subnips{1} '/Sess2_OA888A1J.EDF'];
    raw_data_file{3} = [dat_path subnips{1} '/Sess3_OA888A22.EDF'];
elseif strcmp(subnips, 'LJ')
    pre_mri_file = [mri_path subnips{1} '/co20171024_090830t1mprsagp2isos004a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/co20171024_130847t1mprsagp2isos004a1001.nii.gz']; 
    raw_data_file{1} = [dat_path subnips{1} '/OA8887R9.EDF'];
elseif strcmp(subnips, 'AS')
    pre_mri_file = [mri_path subnips{1} '/co20170918_143405t1mprsagp2iso09320s006a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/AS_rawCT_rawMRI.nii.gz'];
    %post_ct_file = [ct_path subnips{1} '/o20180117_10282101CCTXCARESAFIREs003a002.nii.gz']; 
    raw_data_file{1} = [dat_path subnips{1} '/OA8889H8.EDF'];
elseif strcmp(subnips, 'SB')
    pre_mri_file = [mri_path subnips{1} '/co20171024_080407t1mprsagp2iso09320s007a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/o20180130_11424101CCTXCAREs006a002A.nii.gz'];
    %post_ct_file = [ct_path subnips{1} '/o20180117_10282101CCTXCARESAFIREs003a002.nii.gz']; 
    raw_data_file{1} = [dat_path subnips{1} '/Sess1_OA8889SV.EDF'];
    raw_data_file{2} = [dat_path subnips{1} '/Sess2_OA8889V2.EDF'];
elseif strcmp(subnips, 'HL')
    pre_mri_file = [mri_path subnips{1} '/co20170503_145752t1mprsagp2iso09320s006a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/o20180515_12194201CCTXCAREs003a002.nii.gz'];
    %post_ct_file = [ct_path subnips{1} '/o20180117_10282101CCTXCARESAFIREs003a002.nii.gz']; 
    raw_data_file{1} = [dat_path subnips{1} '/Sess1_OA888C2X.EDF'];
    raw_data_file{2} = [dat_path subnips{1} '/Sess2_OA888C6F.EDF'];
elseif strcmp(subnips, 'AP')
    pre_mri_file = [mri_path subnips{1} '/co20180803_111256t1mprsagp2iso083203Ds023a1001.nii.gz'];
    post_ct_file = [ct_path subnips{1} '/o20180808_09410301CCTXCAREs003a002.nii.gz'];
    raw_data_file{1} = [dat_path subnips{1} '/Sess1_OA888E1N.EDF'];
    raw_data_file{2} = [dat_path subnips{1} '/Sess2_KA004F9C.EDF'];
end
%% %% Anatomical preprocessing %% %%

%% Read in mri/ct scans and check their orientations
mri = ft_read_mri(pre_mri_file);
ft_determine_coordsys(mri);

ct = ft_read_mri(post_ct_file);
ft_determine_coordsys(ct);

%% Align mri/ct scans to specific coordinate system (or just look at the scans)
%Mri
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'acpc';
mri_acpc = ft_volumerealign(cfg, mri);

%Write to nifti
cfg = [];
cfg.filename = [mri_path subnips{1} '/' subnips{1} '_MR_acpc'];
cfg.filetype = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri_acpc);

%Ct
if ~strcmp(subnips{1}, 'LJ')
    cfg = [];
    cfg.method = 'interactive';
    cfg.coordsys = 'ctf';
    ct_ctf = ft_volumerealign(cfg, ct);

    ct_acpc = ft_convert_coordsys(ct_ctf, 'acpc');

    %Write to nifti
    cfg = [];
    cfg.filename = [ct_path subnips{1} '/' subnips{1} '_CT_ctf'];
    cfg.filetype = 'nifti';
    cfg.parameter = 'anatomy';
    ft_volumewrite(cfg, ct_ctf);
else
    %Mri (instead of post-op CT)
    cfg = [];
    cfg.method = 'interactive';
    cfg.coordsys = 'acpc';
    ct_acpc = ft_volumerealign(cfg, ct);
end

%Conversion to acpc didn't work for all subjects
if ~strcmp(subnips{1}, 'EG_I') && ~strcmp(subnips{1}, 'WS') && ~strcmp(subnips{1}, 'HL')
    cfg = [];
    cfg.filename = [ct_path subnips{1} '/' subnips{1} '_CT_acpc'];
    cfg.filetype = 'nifti';
    cfg.parameter = 'anatomy';
    ft_volumewrite(cfg, ct_acpc);
end

%% First quality check: Fuse MRI with CT scan
cfg = [];
cfg.method = 'spm';
cfg.spmversion = 'spm12';
cfg.coordsys = 'acpc';
cfg.viewresult = 'yes';

if exist('ct_acpc')
    ct_acpc_f = ft_volumerealign(cfg, ct_acpc, mri_acpc);
else
    ct_acpc_f = ft_volumerealign(cfg, ct_ctf, mri_acpc);
end

%% FreeSurfer (takes ~10h)
fshome = '/usr/local/freesurfer';
subdir = [mri_path subnips{1} '/'];
mrfile = [mri_path subnips{1} '/' subnips{1} '_MR_acpc.nii'];
system(['export FREESURFER_HOME=' fshome '; '...
  'source $FREESURFER_HOME/SetUpFreeSurfer.sh; ' ...
  'mri_convert -c -oc 0 0 0 ' mrfile ' ' [subdir '/tmp.nii'] '; ' ...
  'recon-all -i ' [subdir '/tmp.nii'] ' -s ' 'freesurfer' ' -sd ' ...
  subdir ' -all']);

%% Quality check of extracted cortical surfaces
pial_file = {'/freesurfer/surf/lh.pial', '/freesurfer/surf/rh.pial'};

for hemi = 1 : length(pial_file)
    pial = ft_read_headshape([mri_path subnips{1} pial_file{hemi}]);
    %pial = ft_read_headshape([pial_file{hemi}]);
    pial.coordsys = 'acpc';
     
    ft_plot_mesh(pial);
    material dull; lighting gouraud; camlight;
     
    pause;
end

%% Import freesurfer-processed MRI as well as CT
fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
%fsmri_acpc = ft_read_mri(['/media/darinka/Data0/iEEG/scripts/MRI_CT/SubjectUCI29/freesurfer/mri/T1.mgz']);
fsmri_acpc.coordsys = 'acpc';

%Write to nifti
cfg = [];
cfg.filename = [mri_path subnips{1} '/' subnips{1} '_MR_acpc_f'];
cfg.filetype = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, fsmri_acpc);

%Determine whether the ct fused with the mri will be the one in the acpc
%system or the ctf system
if strcmp(subnips{1}, 'MKL')
    %ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_acpc_fsl_fs.nii.gz']); %this CT_file was first fused with the freesurfer MRI in fsl
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_acpc.nii']);
    ct_acpc.coordsys = 'acpc';
elseif strcmp(subnips{1}, 'EG_I')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_ctf.nii']);
    ct_acpc.coordsys = 'ctf';
elseif strcmp(subnips{1}, 'HS')
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_acpc_MR_acpc_f_fsl.nii.gz']); %co-registration did not work for either CT_ctf nor CT_acpc, so I first aligned the latter scan with the freesurfer MRI in fsl
    ct_acpc.coordsys = 'acpc';
elseif strcmp(subnips{1}, 'MG')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_ctf_MR_acpc_f_fsl_dof12.nii.gz']); %could not re-orient CT_ctf to acpc and co-registration of this did not work with freesurfer MRI, so I first used flirt to re-align CT_ctf and MR_acpc_f
    ct_acpc.coordsys = 'acpc';
elseif strcmp(subnips{1}, 'KR')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_ctf.nii']); 
    ct_acpc.coordsys = 'ctf';
elseif strcmp(subnips{1}, 'WS')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_ctf.nii']); 
    ct_acpc.coordsys = 'ctf';
elseif strcmp(subnips{1}, 'KR_I')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_acpc_MR_acpc_f_fsl_dof12.nii.gz']);  %co-registration did not work for either CT_ctf nor CT_acpc, so I first aligned the latter scan with the freesurfer MRI in fsl
    ct_acpc.coordsys = 'acpc';
elseif strcmp(subnips{1}, 'LJ')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_acpc.nii']);  %this is actually an MRI scan
    ct_acpc.coordsys = 'acpc';
elseif strcmp(subnips{1}, 'AS')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_rawCT_rawMRI.nii.gz']); %could not co-register fs MRI with either ctf or acpc CT, so I basically just used the raw CT that had been co-registered with the raw MRI  
    ct_acpc.coordsys = 'acpc';
elseif strcmp(subnips{1}, 'SB')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_acpc_MR_acpc_f_fsl_dof12.nii.gz']); 
    ct_acpc.coordsys = 'acpc';
elseif strcmp(subnips{1}, 'HL')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_ctf.nii']); 
    ct_acpc.coordsys = 'ctf';
elseif strcmp(subnips{1}, 'AP')
    fsmri_acpc = ft_read_mri([mri_path subnips{1} '/freesurfer/mri/T1.mgz']);
    ct_acpc = ft_read_mri([ct_path subnips{1} '/' subnips{1} '_CT_ctf.nii']); 
    ct_acpc.coordsys = 'ctf';
end

%% Fuse MRI with CT scan and save resulting file
cfg = [];
cfg.method = 'spm';
cfg.spmversion = 'spm12';
cfg.coordsys = 'acpc';
cfg.viewresult = 'yes';

ct_acpc_f = ft_volumerealign(cfg, ct_acpc, fsmri_acpc);

%Save
cfg = [];
cfg.filename = [ct_path subnips{1} '/' subnips{1} '_CT_acpc_f'];
cfg.filetype = 'nifti';
cfg.parameter = 'anatomy';
cfg.coordsys = 'acpc';

ft_volumewrite(cfg, ct_acpc_f);

%% Electrode placement

%Read in channel info from edf file
for sessi = 1 : length(raw_data_file)
    hdr_tmp{sessi} = ft_read_header(raw_data_file{sessi});
end

exclude_chans = {'DC','TP9','TP10', 'EKG','X','-','E'};
remain_chan_ind = sum(cell2mat(cellfun(@(x) startsWith(hdr_tmp{1}.label, x), exclude_chans, 'un', 0)), 2) == 0;

hdr.nChans = sum(remain_chan_ind);
hdr.label = hdr_tmp{1}.label(remain_chan_ind);

cfg = [];
cfg.channel = hdr.label;

if strcmp(subnips{1}, 'LJ')
    cfg.magtype = 'trough';
end

elec_acpc_f = ft_electrodeplacement(cfg, ct_acpc_f, fsmri_acpc);

%% Quality check
ft_plot_ortho(fsmri_acpc.anatomy, 'transform', fsmri_acpc.transform, 'style', 'intersect');
ft_plot_sens(elec_acpc_f, 'label', 'on', 'fontcolor', 'w');

save([ct_path subnips{1} '/' subnips{1} '_elec_acpc_f.mat'], 'elec_acpc_f');

%% Brain-shift compensation (optional for cortical grids/strips; takes quite a while)
pial_file = {'/freesurfer/surf/lh.pial', '/freesurfer/surf/rh.pial'};
file_name = {'_hull_lh.mat', '_hull_rh.mat'};

if strcmp(subnips{1}, 'HS')
    grids = {'FLR*', 'TLR*', 'TBAR*', 'TBMR*', 'TBPR*', 'TBOR*'};
elseif strcmp(subnips{1}, 'MG')
    grids = {'FL*', 'CP*', 'TLS*', 'TLI*', 'CA*', 'HIP*', 'TBP*', 'OB*'};
elseif strcmp(subnips{1}, 'KJ_I')
    grids = {'FLR*', 'PLR*', 'TLR*', 'TIA*', 'TIM*', 'TIP*'};
elseif strcmp(subnips{1}, 'AS')
    grids = {'FPL*', 'FL*'}; %left hemisphere only!
elseif strcmp(subnips{1}, 'AP')
    grids = {'TLL*', 'TAL*', 'TML*', 'TPL*', 'TLR*', 'TAR*', 'TMR*', 'TPR*'};
end

%First, create smooth hull around the cortical mesh created by
%Freesurfer
for hemi = 1 : 2
    cfg = [];
    cfg.method = 'cortexhull';
    cfg.headshape = [mri_path subnips{1} pial_file{hemi}];
    cfg.fshome = '/usr/local/freesurfer'; %also had to upd
        
    hull = ft_prepare_mesh(cfg);
        
    save([mri_path subnips{1} '/' subnips{1} file_name{hemi}], 'hull');
end

%Then, project the electrode grids to the surface hull of the implanted
%hemisphere (start with the left)
elec_acpc_fr = elec_acpc_f;

for gridi = 1 : numel(grids)
    cfg = [];
    cfg.channel = grids{gridi};
    cfg.keepchannel = 'yes';
    cfg.elec = elec_acpc_fr;
    cfg.method = 'headshape';
    
    if strcmp(subnips{1}, 'HS') || strcmp(subnips{1}, 'MG') || strcmp(subnips{1}, 'KJ_I')
        load([mri_path subnips{1} '/' subnips{1} '_hull_rh.mat']);
    elseif strcmp(subnips{1}, 'AS')
        load([mri_path subnips{1} '/' subnips{1} '_hull_lh.mat']);
    elseif strcmp(subnips{1}, 'AP')
        if gridi <= 4
            load([mri_path subnips{1} '/' subnips{1} '_hull_lh.mat']);
        else
            load([mri_path subnips{1} '/' subnips{1} '_hull_rh.mat']);
        end
    end

    cfg.headshape = hull;

    cfg.warp = 'dykstra2012';
    %cfg.warp = 'hermes2010';
    cfg.feedback = 'yes';
        
    elec_acpc_fr = ft_electroderealign(cfg);
end
    
%Visualize the cortex and electrodes together and examine whether they
%show the expected behavior
pial = ft_read_headshape([mri_path subnips{1} pial_file{2}]);
    
figure;
ft_plot_mesh(pial);
ft_plot_sens(elec_acpc_fr);
view([-55 10]); 
material dull; 
lighting gouraud; 
camlight;
    
%Save
save([ct_path subnips{1} '/' subnips{1} '_elec_acpc_fr.mat'], 'elec_acpc_fr'); %One of the electrodes seems a bit weirdly placed (to be seen)

%% Volume-based registration (optional)
%First, add info about coordsys to fsmri
fsmri_acpc.coordsys = 'acpc';

cfg = [];

if strcmp(subnips{1}, 'MKL')
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
    cfg.spmmethod = 'new';
elseif strcmp(subnips{1}, 'EG_I') 
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
elseif strcmp(subnips{1}, 'HS')
    %cfg.nonlinear = 'yes';
    %cfg.spmversion = 'spm8';
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
    cfg.spmmethod = 'new';
elseif strcmp(subnips{1}, 'MG')
    %cfg.spmversion = 'spm8';
    %cfg.nonlinear = 'yes';
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
    cfg.spmmethod = 'new';
elseif strcmp(subnips{1}, 'KR')
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
elseif strcmp(subnips{1}, 'WS')
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
elseif strcmp(subnips{1}, 'KJ_I')
    %cfg.nonlinear = 'yes';
    %cfg.spmversion = 'spm12';
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
    cfg.spmmethod = 'new';
elseif strcmp(subnips{1}, 'LJ')
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
elseif strcmp(subnips{1}, 'AS')
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
elseif strcmp(subnips{1}, 'SB')
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
elseif strcmp(subnips{1}, 'HL')
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
elseif strcmp(subnips{1}, 'AP')
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
    cfg.spmmethod = 'new';
end

fsmri_mni = ft_volumenormalise(cfg, fsmri_acpc);

%Obtain electrode position in standard MNI space
if ~exist ('elec_acpc_fr')
    elec_acpc_fr = elec_acpc_f;
end

elec_mni_frv = elec_acpc_fr;
elec_mni_frv.elecpos = ft_warp_apply(fsmri_mni.params, elec_acpc_fr.elecpos, 'individual2sn');
elec_mni_frv.chanpos = ft_warp_apply(fsmri_mni.params, elec_acpc_fr.chanpos, 'individual2sn');
elec_mni_frv.coordsys = 'mni';

%Plot as quality check
load(['/usr/local/Fieldtrip/fieldtrip-20190329/template/anatomy/surface_pial_both.mat']);
ft_plot_mesh(mesh);
ft_plot_sens(elec_mni_frv);
view([-90 20]); 
material dull; lighting gouraud; 
camlight;

%Save
save([ct_path subnips{1} '/' subnips{1} '_elec_mni_frv.mat'], 'elec_mni_frv');

%% Surface-based registration (for cortical grids only): This still needs fixing!
cfg = [];

if strcmp(subnips{1}, 'MG')
    cfg.channel = {'FL*', 'CP*', 'TLS*', 'TLI*', 'CA*', 'HIP*', 'TBP*', 'OB*'};
    cfg.headshape = [mri_path subnips{1} '/freesurfer/surf/rh.pial'];
end

cfg.elec = elec_acpc_fr;
cfg.method = 'headshape';
cfg.warp = 'fsaverage';
cfg.fshome = '/usr/local/freesurfer';

which read_surf

elec_fsavg_frs = ft_electroderealign(cfg);
 


%% Anatomical labeling (takes ~ 1 hour)
xldir = [script_path '20130227_xlwrite'];
fsdir = [mri_path subnips{1} '/freesurfer'];

M.xldir = xldir;
M.fsdir = fsdir;
M.elec_nat = elec_acpc_fr;
M.elec_mni = elec_mni_frv;

e_pos = ['/media/darinka/Data0/iEEG/Results/Electrodes/' subnips{1} '/' subnips{1} '_elec_pos.xlsx'];
table = generate_electable(e_pos, 'xldir', xldir, 'fsdir', fsdir, 'elec_nat', elec_acpc_fr, 'elec_mni', elec_mni_frv);

%% %% Functional preprocessing %% %%

%% Load in data
for sessi = 1 : length(raw_data_file)
    
    disp(num2str(sessi));
    
    cfg = [];
    cfg.dataset = raw_data_file{sessi}; 

    cfg.continuous = 'yes';
    data{sessi} = ft_preprocessing(cfg);
end

%% Extract trigger channels
for sessi = 1 : length(raw_data_file)
    data_trig{sessi} = data{sessi}.trial{1}(startsWith(data{sessi}.label, 'DC'), :);
end

%% Binarize triggers: everything over 10 (uV?) counts as bit-on, otherwise as bit-off
for sessi = 1 : length(raw_data_file)
    data_trig{sessi} = data_trig{sessi} > 10;
end

%% Combine bits into a single trigger channel
for sessi = 1 : length(raw_data_file)
    trigchan{sessi} = zeros(1, size(data_trig{sessi}, 2));
    
    for eventi = 1 : size(data_trig{sessi}, 1)
        trigchan{sessi} = trigchan{sessi} + data_trig{sessi}(eventi, :) * 2^(eventi - 1);
    end
end

%% Extract actual trigger values and sample indices
for sessi = 1 : length(raw_data_file)
    trigsamp{sessi} = []; %sample indices of trigger onsets
    trigval{sessi} = []; %actual trigger values
    
    my_difference{sessi} = diff(trigchan{sessi});
    tmp{sessi} = my_difference{sessi} > 0; %identify those segments in which values changed abruptly
    
    %Ignore triggers that are too short (i.e., < 16 samples) or within 16 samples of the end of the recording.
    %This step seems necessary since not all of the digital lines switch on at
    %exactly that sample, which can result in weird trigger values during
    %the up- or downflank. 
    for eventi = find(tmp{sessi})
        if eventi < numel(tmp{sessi}) - 16 && any(tmp{sessi}(eventi + 1 : eventi + 16))
            continue;
        else
            trigsamp{sessi}(end + 1) = eventi + 1;
            trigval{sessi}(end + 1) = trigchan{sessi}(eventi + 1);
        end
    end  
    
    %Check whether the triggers seem to make sense
    figure;
    plot(trigsamp{sessi}, trigval{sessi});
end

%% Check triggers and compare them to the behavioral data
load([behavior_path subnips{1} '_memory_behavior.mat']);

for sessi = 1 : length(raw_data_file)
    [alltrig{sessi}, alltimes{sessi}, durations{sessi}, data_mem] = ECoG_checkTriggers(trigval{sessi}, trigsamp{sessi}, sessi, data_mem, subnips{1}, data{sessi}.fsample);
end

save([res_path subnips{1} '/' subnips{1} '_alltrig.mat'], 'alltrig', 'alltimes');
save([behavior_path subnips{1} '_memory_behavior.mat'], 'data_mem');
%% Create trial structure so that each epoch will be aligned to cue onset 
%As of now, this will necessarily lead to epochs of different lengths, as
%the endsample will correspond to RT.
% Cue = 0, Begin sample = 450 ms before cue onset, End sample = RT

%Check sample frequency
if data{1}.fsample ~= 1000
    display('Attention! Different sample frequency ...');
end

if ~strcmp(subnips, 'KJ_I') && ~ strcmp(subnips, 'SB') && ~strcmp(subnips, 'HL') && ~strcmp(subnips, 'MKL')
    for sessi = 1 : length(raw_data_file)
        trl{sessi} = [alltimes{sessi}(:, 2)-450, alltimes{sessi}(:, 7), ones(size(alltrig{sessi}, 1), 1)*-450];  %matrix: [beginning sample, end sample, offset of 
    end
elseif strcmp(subnips, 'KJ_I') || strcmp(subnips, 'SB') || strcmp(subnips, 'MKL')
    for sessi = 1 : length(raw_data_file)
        if strcmp(subnips, 'MKL') && (sessi == 1)
            trl{sessi} = [alltimes{sessi}(:, 2)-880, alltimes{sessi}(:, 7), ones(size(alltrig{sessi}, 1), 1)*-880];  %matrix: [beginning sample, end sample, offset of 
        else
            trl{sessi} = [alltimes{sessi}(:, 2)-900, alltimes{sessi}(:, 7), ones(size(alltrig{sessi}, 1), 1)*-900];  %matrix: [beginning sample, end sample, offset of 
        end
    end
elseif strcmp(subnips, 'HL') %sampling frequency of 200!
      for sessi = 1 : length(raw_data_file)
        trl{sessi} = [alltimes{sessi}(:, 2)-90, alltimes{sessi}(:, 7), ones(size(alltrig{sessi}, 1), 1)*-90];  %matrix: [beginning sample, end sample, offset of 
    end
end

%% Exclude non-EEG channels
if strcmp(subnips{1}, 'MKL')
    channels = {'FbR*', 'FR*', 'FlR*', 'FbL*', 'FL*'};
elseif strcmp(subnips{1}, 'EG_I')
    channels = {'FAL*', 'FAR*', 'FBL*', 'FLL*'};
elseif strcmp(subnips{1}, 'HS')
    channels = {'FLR*', 'TLR*', 'TBAR*', 'TBMR*', 'TBPR*', 'TBOR*', 'AHL*', 'DHL*'};
elseif strcmp(subnips{1}, 'MG')
    channels =  {'CP*', 'FL*', 'TLS*', 'TLI*', 'CA*', 'HIP*', 'TBP*', 'OB*'};
elseif strcmp(subnips{1}, 'KR')
    channels =  {'FIR*', 'TAR*', 'THR*', 'FAR*', 'FPR*', 'FL*'};
elseif strcmp(subnips{1}, 'WS')
   channels =  {'FBR*', 'IAR*', 'FLR*', 'TSR*', 'HKR*', 'FLL*', 'HKL*'}; 
elseif strcmp(subnips{1}, 'KJ_I')
    channels = {'FLR*', 'PLR*', 'TLR*', 'TIA*', 'TIM*', 'TIP*'};
elseif strcmp(subnips{1}, 'LJ')
    channels = {'LFL*', 'LFM*', 'CA*', 'LTA*', 'HIP*', 'LPS*', 'LFB*'};
elseif strcmp(subnips{1}, 'AS')
    channels = {'FPL*', 'FL*'};
elseif strcmp(subnips{1}, 'SB')
    channels = {'FR*', 'FAL*', 'FLL*', 'FPL*'};
elseif strcmp(subnips{1}, 'HL')
    channels = {'BAR*', 'ALR*', 'PLR*', 'MER*', 'SMR*', 'MEL*'};
elseif strcmp(subnips{1}, 'AP')
    channels = {'TLL*', 'TAL*', 'TML*', 'TPL*', 'TLR*', 'TAR*', 'TMR*', 'TPR*'};
end

cfg = [];
cfg.channel = channels;

for sessi = 1 : length(raw_data_file)
    sel_data{sessi} = ft_selectdata(cfg, data{sessi});
end

%% Quality check: Quick look at frequency spectrum
for sessi = 1 : length(raw_data_file)
    cfg = [];
    cfg.method = 'mtmfft';
    cfg.taper = 'hanning';
    cfg.pad = 'nextpow2';
    
    freq_spec{sessi}  = ft_freqanalysis(cfg, sel_data{sessi});

    freq_spec{sessi}.logspctrm = log10(freq_spec{sessi}.powspctrm);
    
    %Plot
    cfg = [];
    cfg.parameter = 'logspctrm';
    
    ft_singleplotER(cfg,freq_spec{sessi});
    
    pause;
end

clear freq_spec; 
%% Filter the data for high-frequency and power-line noise
for sessi = 1 : length(raw_data_file)
    cfg = [];
    cfg.demean = 'yes';
    cfg.baselinewindow = 'all';
    cfg.bpfilter = 'yes';
    if ~strcmp(subnips{1}, 'HL')
        cfg.bpfreq = [0.2 240];
    else
        cfg.bpfreq = [0.2 98];
    end
    cfg.bsfilter = 'yes';
    cfg.bsfiltord = 3;
    
    if ~strcmp(subnips{1}, 'HL')
        cfg.bsfreq = [49 51; 99 101; 149 151; 199 201];
    else
        cfg.bsfreq = [49 51];
    end

    data_filtered{sessi} = ft_preprocessing(cfg, sel_data{sessi});
end

save([res_path subnips{1} '/' subnips{1} '_filtered.mat'], 'data_filtered', '-v7.3');
%% Append sessions
if ~strcmp(subnips{1}, 'MG') && ~strcmp(subnips{1}, 'KR') && ~strcmp(subnips{1}, 'KJ_I') && ~strcmp(subnips{1}, 'LJ') && ~strcmp(subnips{1}, 'AS') && ~strcmp(subnips{1}, 'HL')
    data_combined = rmfield(data_filtered{1}, {'hdr', 'cfg', 'trial'});
    data_combined.trial = {[data_filtered{1}.trial{1}, data_filtered{2}.trial{1}]};
    data_combined.time = {[data_filtered{1}.time{1} (data_filtered{2}.time{1} + max(data_filtered{1}.time{1}) + 1/data_filtered{1}.fsample)]};
    data_combined.sampleinfo = size(data_combined.time{1});

    trl_combined = [trl{1};(trl{2} + max(data_filtered{1}.sampleinfo))];
    
    if ~strcmp(subnips{1}, 'SB') && ~strcmp(subnips{1}, 'HL') && ~strcmp(subnips{1}, 'MKL')
        trl_combined(:, 3) = -450;
    elseif strcmp(subnips{1}, 'SB') || strcmp(subnips{1}, 'MKL')
        if ~strcmp(subnips{1}, 'MKL')
            trl_combined(:, 3) = -900;
        else
            trl_combined(1 : 618, 3) = -880;
            trl_combined(619 : 658, 3) = -900;
        end
    end
elseif strcmp(subnips{1}, 'MG') || strcmp(subnips{1}, 'KJ_I')
    data_combined = rmfield(data_filtered{1}, {'hdr', 'cfg', 'trial'});
    data_combined.trial = {[data_filtered{1}.trial{1}, data_filtered{2}.trial{1}, data_filtered{3}.trial{1}]};
    data_combined.time = {[data_filtered{1}.time{1} (data_filtered{2}.time{1} + max(data_filtered{1}.time{1}) + 1/data_filtered{1}.fsample)]};
    data_combined.time = {[data_combined.time{1} (data_filtered{3}.time{1} + max(data_combined.time{1}) + 1/data_filtered{1}.fsample)]};
    data_combined.sampleinfo = size(data_combined.time{1});

    trl_combined = [trl{1}; (trl{2} + max(data_filtered{1}.sampleinfo)); (trl{3} + max(data_filtered{1}.sampleinfo) + max(data_filtered{2}.sampleinfo))];
    if strcmp(subnips{1}, 'MG')
        trl_combined(:, 3) = -450;
    elseif strcmp(subnips{1}, 'KJ_I') %due to initial sample frequency of 2000 instead of 1000
        trl_combined(:, 3) = -900;
    end
elseif strcmp(subnips{1}, 'KR') || strcmp(subnips{1}, 'LJ') || strcmp(subnips{1}, 'AS') || strcmp(subnips{1}, 'HL')
    data_combined = rmfield(data_filtered{1}, {'hdr', 'cfg', 'trial'});
    data_combined.trial = {[data_filtered{1}.trial{1}]};
    data_combined.time = {[data_filtered{1}.time{1}]};
    data_combined.sampleinfo = size(data_combined.time{1});

    trl_combined = [trl{1}];
    
    if ~strcmp(subnips{1}, 'HL')
        trl_combined(:, 3) = -450;
    else
        trl_combined(:, 3) = -90;
    end
end

save([res_path subnips{1} '/' subnips{1} '_combined.mat'], 'data_combined', 'trl_combined', '-v7.3');

%% Epoch data
cfg = [];
cfg.trl = trl_combined;

data_epoched = ft_redefinetrial(cfg, data_combined);

save([res_path subnips{1} '/' subnips{1} '_epoched.mat'], 'data_epoched', '-v7.3');
%% Clear up some RAM
clear ('data', 'data_filtered', 'data_combined');

data = data_epoched;

clear('data_epoched');

%% Quick check to see whether epoching worked by plotting ERF
cfg = [];
cfg.latency = [-0.2, 5.0];

data_avg = ft_timelockanalysis(cfg, data);

figure;
plot(data_avg.time, mean(data_avg.avg,1), 'k-');

figure;
plot(data_avg.time, data_avg.avg);

clear ('data_avg');

%% Resample if needed
cfg = [];
cfg.resamplefs = 1000;
cfg.sampleinfo = data.sampleinfo;

data = ft_resampledata(cfg, data);

save([res_path subnips{1} '/' subnips{1} '_resampled.mat'], 'data', '-v7.3');

%% Add electrode information extracted from anatomical workflow to data
data.elec = elec_acpc_fr;
data.elec_mni_frv = elec_mni_frv;

save([res_path subnips{1} '/' subnips{1} '_beforeExclusion.mat'], 'data', '-v7.3');

%% Visual inspection in preparation for artifact rejection (pre-rereferencing)

%First, look at all trials from all channels to get an idea of potentially
%critical channels
cfg = [];
cfg.method = 'channel';
cfg.preproc.demean = 'yes';

data_tmp = ft_rejectvisual(cfg, data);

%Summary statistics
cfg = [];
cfg.method = 'summary';
cfg.alim = 1e-12; 

data_tmp = ft_rejectvisual(cfg, data); 

%Identifying poor channels
cfg = [];
cfg.viewmode = 'vertical';

cfg = ft_databrowser(cfg, data);

%Individual trials
cfg = [];
cfg.trl = 'yes';
cfg.viewmode = 'vertical';

cfg_pre = ft_databrowser(cfg, data);

%% Exclude potential ground/reference electrodes and obviously bad channels
if strcmp(subnips{1}, 'MKL')
    bad_channels = {'all', '-FR5', '-FR6', '-FbR1-1', '-FbR1-2', '-FbR1-3', '-FbR1-4', '-FbR1-5', ...
        '-FbL1', '-FbL1-1', '-FbL1-2', '-FbL1-3', '-FbL1-4', '-FbL1-5', '-FlR8', '-FlR9', '-FlR1-1', ...
        '-FlR1-2'};
     selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'EG_I')
    bad_channels = {'all', '-FAL1', '-FAL2', '-FAL3', '-FAL4', '-FAL5', '-FAL6', '-FAR6', '-FAR7', '-FLL1-3'};
    selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'HS')
    bad_channels = {'all', '-FLR5', '-FLR6', '-TBMR', '-TBMR-1', '-TBMR-2', '-TBMR-3', '-TBPR', '-TBPR-1',...
        '-TBOR', '-TBOR-3', '-TBOR-4', '-TBOR-5', '-AHL1', '-AHL2', '-AHL3', '-AHL9', '-AHL1-1', '-DHL1', '-DHL2', ...
        '-TLR7', '-TLR8', '-TLR1-3', '-TLR1-5', '-TLR1-6', '-TLR1-7', '-TBAR-2', '-TBAR-3'};
    selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'MG')
    bad_channels = {'all', '-CP1', '-CP3', '-CP5', '-CP6', '-CP8', '-TLS1', '-TLS2',  '-TLS3', '-TLS7', '-TLS8',  '-TLS9', ...
        '-TLS1-1', '-TLS1-2',  '-TLS1-3', '-OB6', '-TLI1', '-TLI2', '-TLI3', '-TLI5', '-TLI6', '-TLI7',  '-TLI9', '-TLI1-2', '-TLI1-3', ...
        '-TBP5', '-HIP1', '-HIP3', '-HIP4'};
    selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'KR')
     bad_channels = {'all', '-FIR5', '-FIR6', '-FIR8', '-FIR1-2', '-FIR1-3', '-FIR1-5', '-TAR7', '-TAR1-3', '-FL13', ...
         '-FAR7', '-FPR4', '-FPR5', '-THR1', '-THR1-3', '-THR1-4'};
     selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'WS')
    bad_channels = {'all', '-FBR4', '-FBR5', '-FBR6', '-FBR7', '-FBR1-3', '-HKL*', '-FLR3', '-FLR5', '-FLR6', ...
        '-FLR7', '-FLR8', '-FLR9', '-FLR1-1', '-FLR1-2', '-HKR1', '-HKR2', '-HKR3', '-HKR6', '-HKR7', '-HKR8', ...
        '-HKR9', '-HKR1-1', '-FBR4', '-FBR7', '-FBR1-3', '-FLL7', '-FLL1-2', '-IAR1', '-IAR2', '-IAR3', '-TSR7'};
    selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'KJ_I')
    bad_channels = {'all', '-TLR5', '-TLR6', '-TLR7', '-TLR9', '-TLR1-2', '-TLR1-3', '-TLR1-7', '-TIM1', '-TIP3', ...
        '-TIP4', '-TIA1', '-TIA2', '-TIA3', '-TIA5', '-FLR3'};
    selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'LJ')
    bad_channels = {'all', '-LTA4', '-LTA5', '-LTA6', '-LTA9', '-HIP1', '-HIP2', '-HIP3', '-HIP7', '-HIP1-3', ...
        '-LFL1', '-LFL2', '-LFL3', '-LFL1-1', '-LFL1-2', '-CA1', '-CA2', '-CA3', '-CA11', ...
        '-LPS8', '-LFB2', '-LFB6', '-LFB8'};
     selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'AS')
    bad_channels = {'all', '-FL5', '-FL6', '-FL16', '-FL24', '-FL31', '-FL32', '-FL34', '-FL39', '-FL42', ...
        '-FL46', '-FPL2', '-FPL3', '-FPL8', '-FPL9'};
    selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'SB')
    bad_channels = {'all', '-FPL*', '-FAL1*', '-FAL2*', '-FAL3*', '-FLL1', '-FLL2', '-FLL3', '-FLL4', '-FLL5'};
    selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'HL')
    bad_channels = {'all', '-SMR1', '-MEL1', '-MEL5', '-MEL6', '-MEL7', '-PLR8', '-MER4', '-MER5', '-MER6', '-MER7', ...
        '-MER8', '-ALR8', '-BAR3', '-BAR6', '-BAR1-1', '-BAR1-2', '-BAR1-3', '-BAR1-4'};
    selchan = ft_channelselection(bad_channels, data.label);
elseif strcmp(subnips{1}, 'AP')
    bad_channels = {'all', '-TMR1', '-TMR2', '-TLL6', '-TLL1-10', '-TLL1-1', '-TLL1-2', '-TLL1-3', '-TLL1-4', ...
        '-TLL2-10', '-TLL2-1', '-TLL2-9', '-TLL3-1', '-TLL3-2', '-TLL3-3', '-TLR4', '-TLR5', '-TML*', '-TAL1', ...
        '-TAl2', '-TPR2'};
    selchan = ft_channelselection(bad_channels, data.label);
end

cfg = [];
cfg.channel = selchan;

data_tmp = ft_selectdata(cfg, data);

%Add original info about all labels and update elec and
%elec_mni_frv
data_tmp.label_all = data.label;
data_tmp.elec_all = elec_acpc_fr;
data_tmp.elec_mni_frv_all = elec_mni_frv;

data_tmp.sampleInfo_all = trl_combined;

if ~strcmp(subnips{1}, 'MG') && ~strcmp(subnips{1}, 'KR') && ~strcmp(subnips{1}, 'KJ_I') && ~strcmp(subnips{1}, 'LJ') ...
        && ~strcmp(subnips{1}, 'AS') && ~strcmp(subnips{1}, 'HL')
    data_tmp.alltrig_all = [alltrig{1}; alltrig{2}];
elseif strcmp(subnips{1}, 'MG') || strcmp(subnips{1}, 'KJ_I')
     data_tmp.alltrig_all = [alltrig{1}; alltrig{2}; alltrig{3}];
elseif strcmp(subnips{1}, 'KR') || strcmp(subnips{1}, 'LJ') || strcmp(subnips{1}, 'AS') || strcmp(subnips{1}, 'HL')
    data_tmp.alltrig_all = [alltrig{1}];
end

%% Exclude bad trials both from EEG and behavioral data
trials_all = 1 : size(data.trial, 2);

if strcmp(subnips{1}, 'MKL')
    bad_trials = [3, 4, 5,  6, 7, 8, 9, 10, 11, 12, 13, 16, 17, 21, 22, 23, 25, 27, ...
        28, 30, 31, 32, 33, 34, 35, 36, 38, 39, 41, 43, 45, 53, 55, 56, 58, 60, 62, ...
        63, 66, 67, 68, 70, 71, 75, 77, 85, 86, 87, 93, 96, 97, 99, 100, 104, 116, ...
        143, 165, 167, 168, 173, 177, 196, 197, 198, 201, 204, 205, 207, 211, 214, ...
        218, 220, 222, 228, 230, 231, 234, 236, 240, 243, 245, 250, 253, 255, 257, ...
        261, 275, 283, 284, 286, 287, 288, 296, 299, 304, 306, 307, 309, 312, 313, ...
        322, 334, 335, 336, 337, 338, 340, 344, 347, 349, 350, 351, 352, 354, 357, ...
        359, 360, 368, 369, 370, 372,  373, 375, 385, 387, 388, 389, 391, 394, 397, ...
        401, 402, 403, 405, 409, 412, 415, 418, 421, 423, 424, 429, 432, 439, 441, ...
        445, 447, 450, 454, 455, 458, 459, 460, 465, 466, 467, 469, 472, 474, 478, ...
        479, 480, 481, 482, 489, 492, 496, 498, 511, 513, 514, 515, 516, 518, 535, ...
        537, 538, 546, 547, 550, 552, 556, 568, 569, 574, 577, 578, 579, 581, 585, ...
        589, 593, 594, 595, 596, 606, 612, 613, 616, 617, 619, 631, 636, 639, 641, ...
        645, 647, 653, 655, 656, 657];
elseif strcmp(subnips{1}, 'EG_I')
    bad_trials = [37:53, 65, 105, 110, 116, 139, 144, 165, 176, 199, 207, 225, ...
        228, 239, 252, 263, 266, 280, 295, 296, 303, 316, 340, 345, 347, 348, 397, ...
        398, 399, 401, 403, 408, 413, 414, 416, 417, 426, 435, 436, 440, 444, 445, ...
        446, 447, 449, 450, 451, 457, 459, 460, 465, 468, 471, 476, 480, 483, 489, ...
        492, 496, 504, 526, 529, 530, 531, 534, 540, 544, 549, 550, 551, 564, 574, ...
        575, 576, 584, 585, 586, 588, 596, 613, 616, 636, 638, 643, 646, 651, 655, ...
        677, 679, 693, 698, 709, 718, 726, 728, 729, 734, 758, 764, 768, 769, 779, ...
        782, 793, 798];  
elseif strcmp(subnips{1}, 'HS')
    bad_trials = [13, 21, 22, 24, 25, 26, 35, 40, 59, 66, 77, 81, 82, 88, 94, 100, 111, ...
        115, 116, 124, 136, 147, 151, 166, 167, 180, 217, 222, 227, 228, 233]; 
elseif strcmp(subnips{1}, 'MG')
    bad_trials = [3, 9, 11, 22, 23, 26, 27, 28, 30, 38, 39, 40, 42, 45, 54, 57, 60, 62, 63, ...
        64, 65, 66, 67, 68, 69, 78, 79, 80, 86, 89, 91, 93, 96, 98, 104, 105, 106, 111, 121, ...
        122, 123, 126, 130, 132, 138, 139, 140, 141, 151, 153, 155, 165, 166, 167, 168, 169, ...
        175, 182, 186, 187, 192, 194, 195, 200, 202, 204, 208, 210, 213, 218, 222, 229, 230, ...
        231, 239, 241, 247, 253, 254, 257, 260, 267, 272, 275, 276, 285, 288, 289, 296, 300, ...
        303, 312, 315, 316, 318, 329, 337, 338, 357, 360, 362, 363, 364, 365, 373, 376, 377, ...
        378, 384, 387, 393, 424, 425, 426, 433, 437, 441, 443, 446, 456, 466, 475, 478, 479, ...
        491, 495, 507, 509, 511, 512, 520, 521, 522, 524, 532, 534, 548, 559, 560, 569, 570, ...
        576, 578, 582, 587, 593, 594, 595, 597, 600, 601, 607, 615, 616, 617, 640, 641, 642, ...
        643, 660, 665, 673, 679, 685, 696, 702, 707, 711, 714, 717, 719, 723, 724, 727, 728, ...
        729, 730, 731, 741, 742, 743, 745, 746, 748, 754, 759, 770, 772, 774, 776, 778, 779, ...
        794, 795, 799, 808, 811, 813, 814];
elseif strcmp(subnips{1}, 'KR')
    bad_trials = [2, 93, 157, 182, 205, 234, 295, 311, 321, 336, 343, 345, 390, 397, 398];
elseif strcmp(subnips{1}, 'WS')
    bad_trials = [1, 7, 10, 11, 12, 13, 14, 16, 17, 25, 27, 28, 30, 37, 39, 41, 48, 49, 50, 52, ...
        56, 71, 74, 76, 82, 83, 84, 86, 88, 89, 91, 92, 97, 98, 100, 104, 107, 111, 115, 116, 117, ...
        118, 123, 127, 128, 129, 130, 139, 141, 144, 146, 150, 151, 153, 155, 159, 160, 163, 164, ...
        166, 167, 169, 172, 175, 176, 182, 183, 184, 189, 191, 194, 195, 199, 201, 202, 206, 209, ...
        213, 215, 216, 217, 218, 219, 222, 226, 227, 228, 233, 234, 235, 237, 240, 247, 248, 251, ...
        254, 258, 259, 260, 263, 268, 271, 274, 276, 278, 281, 288, 289, 293, 294, 295, 296, 301, ...
        302, 308, 313, 314, 318, 319, 320, 330, 337, 339, 342, 347, 348, 349, 352, 355, 359, 362, ...
        364, 367, 369, 370, 371, 374, 379, 383, 384, 385, 386, 387, 392, 397, 398, 416, 417, 422, ...
        427, 430, 432, 443, 450, 474, 482, 499, 567, 592, 599, 601, 604, 613, 663, 665, 679, 680, ...
        701, 712, 719, 721, 733, 742, 754];
elseif strcmp(subnips{1}, 'KJ_I')
    bad_trials = [7, 25, 33, 49, 50, 61, 63, 67, 68, 81, 83, 84,135,  88, 94, 96, 99, 101, 107, 119, ...
        120, 123, 124, 125, 126, 141, 150, 151, 152, 162, 173, 176, 178, 184, 214, 230, 250, 262, 263, ...
        267, 271, 275, 290, 292, 294, 295, 297, 298, 311, 312, 320, 326, 329, 340, 341, 344, 345, 346, ...
        359, 361, 367, 368, 376, 377, 380, 395, 399, 402, 410, 417, 426, 427, 430, 431, 433, 437, 440, ...
        450, 465, 467, 468, 469, 477, 478, 482, 486, 489, 490, 494, 503, 506, 508, 509, 511, 515, 523, ...
        526, 527, 529, 532, 546, 555, 558, 571, 574, 581, 591, 592, 593, 600, 602, 610, 616, 625, 627, ...
        628, 643, 646, 650, 652, 654, 662, 663, 667, 684, 686, 690, 691, 695, 697, 705, 707, 711, 727, ...
        728, 729, 730, 746, 752, 754, 760, 763, 765, 767, 772, 775, 792, 795, 804, 806, 815, 818, 830, ...
        834, 837, 844, 850, 854, 863, 869, 875, 876, 877, 883, 888, 890, 899, 912, 913, 916, 923, 924, ...
        935];
elseif strcmp(subnips{1}, 'LJ')
    bad_trials = [6, 11, 12, 17, 18, 20, 22, 32, 33, 34, 36, 38, 45, 47, 48, 54, 57, 64, 70, 75, 76, 82, ...
        83, 88, 89, 91, 92, 94, 95, 99, 103, 107, 108, 114, 118, 119, 120, 123, 128, 130, 134, 137, 142, ...
        143, 149, 156, 159, 162, 164, 165, 173, 175, 178, 188, 192, 195, 198, 203, 204, 207, 210, 211, ...
        212, 213, 214, 215, 229, 239, 247, 251, 254, 260, 264, 265, 266, 267, 269, 272, 278, 279, 280, ...
        285, 286, 287, 289, 292, 293, 294, 295, 296, 297, 300, 305, 306, 307, 308, 311, 312, 313, 314, ...
        320, 322, 328, 329, 333, 334, 335, 340, 344, 345, 354, 356, 357, 365, 366, 367, 372];
elseif strcmp(subnips{1}, 'AS')
    bad_trials = [1, 9, 11, 17, 22, 23, 31, 37, 39, 40, 41, 42, 45, 48, 49, 62, 67, 81, 82, 84, 88, 91, ...
        94, 107, 108, 126, 130, 133, 139, 146, 163, 196, 219, 262, 275, 276, 278, 280, 284, 302, 310, ...
        322, 330, 334, 335, 341, 344, 361, 370, 376];
elseif strcmp(subnips{1}, 'SB')
    bad_trials = [5, 8, 9, 16, 27, 32, 37, 39, 40, 43, 48, 49, 50, 56, 61, 63, 68, 76, 79, 81, 83, 84, ...
        85, 95, 108, 112, 113, 121, 129, 130, 132, 133, 137, 141, 143, 144, 146, 148, 163, 166, 170, 174, ...
        178, 183, 185, 190, 193, 195, 199, 200, 201, 202, 206, 212, 220, 225, 226, 233, 241, 242, 243, 249, ...
        259, 260, 261, 263, 264, 267, 269, 271, 274, 275, 278, 281, 282, 286, 300, 307, 328, 331, 333, 335, ...
        341, 343, 344, 346, 347, 354, 358, 362, 363, 364, 365, 369, 370, 371, 375, 377, 381, 383, 385, 387, ...
        388, 389, 390, 391, 397, 408, 413, 441, 442, 448, 458, 464, 477, 478, 499, 501, 515, 523, 530, 531, ...
        540];
elseif strcmp(subnips{1}, 'HL')
    bad_trials = [3, 15, 22, 28, 30, 31, 33, 35, 39, 40, 43, 45, 46, 47, 48, 49, 62, 63, 64, 70, 71, 72, ...
        73, 82, 83, 84, 85, 88, 89, 101, 107, 108, 109, 110, 117, 118, 119, 125, 126, 127, 130, 131, 139, ...
        140, 145, 147, 149, 150, 151, 152, 154, 155, 165, 166, 167, 169, 181, 187, 190, 191, 192, 193, 197, ...
        205, 208, 209, 212, 213, 218, 219, 222, 223, 226, 227, 228, 231, 238, 239, 240, 244, 245, 246, 247, ...
        253, 254, 255, 257, 262, 263, 264, 265, 266, 267, 268, 269, 270, 273, 274, 275, 276, 277, 278, 279, ...
        284, 285, 286, 287, 288, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 302, 304, 306, 307, ...
        308, 309, 310, 313, 314, 320, 322, 327, 328, 329, 330, 331, 333, 334, 337, 339, 346, 347, 348, 349, ...
        350, 351, 352, 353, 354, 356, 360, 362, 363, 364, 365, 366, 367, 368, 369, 373, 374, 375, 376, 385, ...
        387, 388, 389, 391, 394, 395, 396, 397, 398];
elseif strcmp(subnips{1}, 'AP')
    bad_trials = [1, 8, 9, 10, 22, 30, 31, 37, 39, 41, 43, 50, 61, 64, 89, 102, 111, 112, 113, 117, 125, ...
        134, 144, 145, 147, 151, 155, 158, 196, 212, 224, 233, 244, 246, 261, 281, 289, 304, 306, 311, 317, ...
        318, 320, 324, 335, 338, 339, 347, 362, 367, 372, 375, 378, 383, 403, 406, 411, 413, 414, 415, 416, ...
        418, 419, 423, 433, 434, 435, 438, 449, 452, 456, 458, 472, 482, 484, 485, 490, 493, 494, 511, 514, ...
        519, 528, 529, 535, 541, 542, 545, 546, 547, 548, 549, 553, 555, 563, 567, 569, 593, 594, 608, 617, ...
        619, 625, 635, 636, 637, 640, 644, 645, 652, 655, 656, 663, 668, 674, 675, 678, 683, 686, 695, 703, ...
        704, 709, 711, 729, 730, 731, 733, 742, 743, 745, 746, 750, 754, 762, 775, 778, 779, 780, 783, 785, ...
        798];
end

trials_all(bad_trials) = []; %indices of included trials
trl_combined(bad_trials, :) = []; 

if ~strcmp(subnips{1}, 'MG') && ~strcmp(subnips{1}, 'KR') && ~strcmp(subnips{1}, 'KJ_I') && ~strcmp(subnips{1}, 'LJ') && ...
        ~strcmp(subnips{1}, 'AS') && ~strcmp(subnips{1}, 'HL')
    alltrig = [alltrig{1}; alltrig{2}];
elseif strcmp(subnips{1}, 'MG') || strcmp(subnips{1}, 'KJ_I')
    alltrig = [alltrig{1}; alltrig{2}; alltrig{3}];
elseif strcmp(subnips{1}, 'KR') || strcmp(subnips{1}, 'LJ') || strcmp(subnips{1}, 'AS') || strcmp(subnips{1}, 'HL')
   alltrig = [alltrig{1}]; 
end

alltrig(bad_trials, :) = [];

%EEG data
cfg =[];
cfg.trials = trials_all;

data_tmp2 = ft_selectdata(cfg, data_tmp);

data_tmp.trial = data_tmp2.trial;
data_tmp.time = data_tmp2.time;

data_tmp.rejTrials = bad_trials;
data_tmp.sampleInfo = trl_combined;
data_tmp.alltrig = alltrig;

data = data_tmp;

save([res_path subnips{1} '/' subnips{1} '_afterExclusion.mat'], 'data', '-v7.3');

clear('data_tmp', 'data_tmp2');

%Behavioral data
if ~strcmp(subnips{1}, 'HS') && ~strcmp(subnips{1}, 'MG') && ~strcmp(subnips{1}, 'HL')
    data_mem.EEG_included = ones(length(data_mem.timing), 1);
    data_mem.EEG_included(bad_trials) = 0;
elseif strcmp(subnips{1}, 'HS')
    data_mem.EEG_included(isnan(data_mem.EEG_included)) = 1;
    data_mem.EEG_included(bad_trials + 4) = 0;
elseif strcmp(subnips{1}, 'MG')
    data_mem.EEG_included(isnan(data_mem.EEG_included)) = 1;
    data_mem.EEG_included(bad_trials(1 : 195)) = 0;
    data_mem.EEG_included(bad_trials(196 : end) + 284) = 0;
elseif strcmp(subnips{1}, 'HL')
    data_mem.EEG_included(isnan(data_mem.EEG_included)) = 1;
    data_mem.EEG_included(bad_trials) = 0;
end

%Save
save([behavior_path subnips{1} '_memory_behavior.mat'], 'data_mem');

%% Re-referencing: Cortical grids
cfg = [];

if strcmp(subnips{1}, 'EG_I') || strcmp(subnips{1}, 'KR')
    cfg.channel = {};
elseif strcmp(subnips{1}, 'HS')
    cfg.channel = {'FLR*', 'TLR*', 'TBAR*', 'TBMR*', 'TBPR*', 'TBOR*', ...
        '-FLR5', '-FLR6', '-TBMR', '-TBMR-1', '-TBMR-2', '-TBMR-3', '-TBPR', '-TBPR-1',...
        '-TBOR', '-TBOR-3', '-TBOR-4', '-TBOR-5', '-TLR7', '-TLR8', '-TLR1-3', '-TLR1-5', ...
        '-TLR1-6', '-TLR1-7', '-TBAR-2', '-TBAR-3'};
    %cfg.channel = {'FLR*', 'TLR*', 'TBAR*', 'TBMR*', 'TBPR*', 'TBOR*'};
elseif strcmp(subnips{1}, 'MG')
    cfg.channel = {'CP*', 'FL*', 'TLS*', 'TLI*', 'CA*', 'HIP*', 'TBP*', 'OB*'};
elseif strcmp(subnips{1}, 'KJ_I')
    cfg.channel = {'FLR*', 'PLR*', 'TLR*', 'TIA*', 'TIM*', 'TIP*'};
elseif strcmp(subnips{1}, 'AS')
    cfg.channel = {'FPL*', 'FL*'};
elseif strcmp(subnips{1}, 'AP')
    cfg.channel = {'TLL*', 'TAL*', 'TPL*', 'TLR*', 'TAR*', 'TMR*', 'TPR*'};
end

cfg.reref = 'yes';
cfg.refchannel = 'all';
cfg.refmethod = 'avg';
cfg.updatesens = 'yes'; %this needs to be added in order to correctly update the .elec field

reref_grids = ft_preprocessing(cfg, data);

reref_grids.elec.chanposold = elec_acpc_fr.chanpos;
reref_grids.elec.labelold = data.label_all;

%Do it again, but this time to update the chanpos for the mni coordinates
data_tmp = data;
data_tmp.elec = data_tmp.elec_mni_frv;

reref_grids_mni = ft_preprocessing(cfg, data_tmp);

reref_grids_mni.elec.chanposold = elec_acpc_fr.chanpos;
reref_grids_mni.elec.labelold = data.label_all;

%% Re-referencing: Depths electrodes
if strcmp(subnips{1}, 'MKL')
    depths = {'FbR*', 'FR*', 'FlR*', 'FbL*', 'FL*'};
elseif strcmp(subnips{1}, 'EG_I')
    depths = {'FAL*', 'FAR*', 'FBL*', 'FLL*'};
elseif strcmp(subnips{1}, 'HS')
    depths = {'DHL*', 'AHL*'};
elseif strcmp(subnips{1}, 'MG')
    depths = {};
elseif strcmp(subnips{1}, 'KR')
    depths = {'FIR*', 'TAR*', 'THR*', 'FAR*', 'FPR*', 'FL*'};
elseif strcmp(subnips{1}, 'WS')
    depths = {'FLL*', 'FBR*', 'FLR*', 'IAR*', 'TSR*', 'HKR*'};
elseif strcmp(subnips{1}, 'LJ')
   depths = {'LFL*', 'LFM*', 'CA*', 'LTA*', 'HIP*', 'LPS*', 'LFB*'};
elseif strcmp(subnips{1}, 'SB')
    depths = {'FAL*', 'FR*'};
elseif strcmp(subnips{1}, 'HL')
    depths = {'BAR*', 'ALR*', 'PLR*', 'MER*', 'SMR*', 'MEL*'};
end

%This automatically updates the chanpos in the data.elec field (so in the
%subject's native space)
for di = 1 : numel(depths)
    
    cfg = [];
    cfg.channel = ft_channelselection(depths{di}, data.label);
    
    if strcmp(subnips{1}, 'HL') || strcmp(subnips{1}, 'MKL')
        cfg.channel = sort(cfg.channel);
    end
    
    cfg.montage.labelold = cfg.channel;
    cfg.montage.labelnew = strcat(cfg.channel(1 : end-1), '-', cfg.channel(2 : end));
    
    %Create a weight matrix 
    tra = zeros(numel(cfg.montage.labelnew), numel(cfg.montage.labelnew) + 1);
    tra = fillin_diag(tra, 0, 1);
    tra = fillin_diag(tra, 1, -1);
    cfg.montage.tra = tra;
    cfg.updatesens = 'yes';
    
    reref_depths{di} = ft_preprocessing(cfg, data);
end

%Combine the data from both electrode types into one data structure
cfg = [];
cfg.appendsens = 'yes';

if strcmp(subnips{1}, 'EG_I') || strcmp(subnips{1}, 'KR') || strcmp(subnips{1}, 'WS') || strcmp(subnips{1}, 'LJ') ...
        || strcmp(subnips{1}, 'SB') || strcmp(subnips{1}, 'HL') || strcmp(subnips{1}, 'MKL')
    reref = ft_appenddata(cfg, reref_depths{:});
elseif ~strcmp(subnips{1}, 'MG') && ~strcmp(subnips{1}, 'KJ_I') && ~strcmp(subnips{1}, 'AS') && ~strcmp(subnips{1}, 'AP')
    reref = ft_appenddata(cfg, reref_grids, reref_depths{:});
else
    reref = ft_appenddata(cfg, reref_grids);
end

%Do it again, but this time to update the chanpos for the mni coordinates
data_tmp = data;
data_tmp.elec = data_tmp.elec_mni_frv;

for di = 1 : numel(depths)
    
    cfg = [];
    cfg.channel = ft_channelselection(depths{di}, data.label);
    
    if strcmp(subnips{1}, 'HL') || strcmp(subnips{1}, 'MKL')
        cfg.channel = sort(cfg.channel);
    end
    
    cfg.montage.labelold = cfg.channel;
    cfg.montage.labelnew = strcat(cfg.channel(1 : end-1), '-', cfg.channel(2 : end));
    
    %Create a weight matrix 
    tra = zeros(numel(cfg.montage.labelnew), numel(cfg.montage.labelnew) + 1);
    tra = fillin_diag(tra, 0, 1);
    tra = fillin_diag(tra, 1, -1);
    cfg.montage.tra = tra;
    cfg.updatesens = 'yes';
    
    reref_depths_mni{di} = ft_preprocessing(cfg, data_tmp);
end

%Combine the data from both electrode types into one data structure
cfg = [];
cfg.appendsens = 'yes';

if strcmp(subnips{1}, 'EG_I') || strcmp(subnips{1}, 'KR') || strcmp(subnips{1}, 'WS') || strcmp(subnips{1}, 'LJ') ...
        || strcmp(subnips{1}, 'SB') || strcmp(subnips{1}, 'HL') || strcmp(subnips{1}, 'MKL')
    reref_mni = ft_appenddata(cfg, reref_depths_mni{:}); 
elseif ~strcmp(subnips{1}, 'MG') && ~strcmp(subnips{1}, 'KJ_I') && ~strcmp(subnips{1}, 'AS') && ~strcmp(subnips{1}, 'AP')
    reref_mni = ft_appenddata(cfg, reref_grids_mni, reref_depths_mni{:}); 
else
    reref_mni = ft_appenddata(cfg, reref_grids_mni);
end

%Put elec_mni back into old file
reref.elec_mni_frv = reref_mni.elec;
reref.label_all = data.label;
reref.elec_all = elec_acpc_fr;
reref.elec_mni_frv_all = elec_mni_frv;

reref.sampleInfo = data.sampleInfo;
reref.alltrig = data.alltrig;
reref.sampleInfo_all = data.sampleInfo_all;
reref.alltrig_all = data.alltrig_all;

%Save
save([res_path subnips{1} '/' subnips{1} '_reref.mat'], 'reref', '-v7.3');



