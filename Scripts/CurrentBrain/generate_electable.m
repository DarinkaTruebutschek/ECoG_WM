function table = generate_electable(filename, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE_ELECTABLE writes an electrode anatomy and annotation table
%
% Use as:
%   generate_electable(filename, ...)
% where filename has an .xlsx file extension,
%
% and at least one of the following sets of key-value pairs is specified:
% elec_mni = electrode structure, with positions in MNI space
% elec_nat = electrode structure, with positions in native space
% fsdir = string, path to freesurfer directory for the subject (e.g. 'SubjectUCI29/freesurfer')
% Ensure FieldTrip is correcty added to the MATLAB path:
%   addpath <path to fieldtrip home directory>
%   ft_defaults
%
% On Mac and Linux, the freely available xlwrite plugin is needed,
% hosted at: http://www.mathworks.com/matlabcentral/fileexchange/38591
%   xldir       = string, path to xlwrite dir (e.g. 'MATLAB/xlwrite')
%
% This function is part of Stolk, Griffin et al., Integrated analysis
% of anatomical and electrophysiological human intracranial data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the optional input arguments
elec_mni        = ft_getopt(varargin, 'elec_mni');
elec_nat        = ft_getopt(varargin, 'elec_nat');
fsdir           = ft_getopt(varargin, 'fsdir');
xldir           = ft_getopt(varargin, 'xldir');
if isunix % on mac and linux
    % add java-based xlwrite to overcome windows-only xlswrite
    addpath(xldir);
    javaaddpath([xldir '/poi_library/poi-3.8-20120326.jar']);
    javaaddpath([xldir '/poi_library/poi-ooxml-3.8-20120326.jar']);
    javaaddpath([xldir ...
    '/poi_library/poi-ooxml-schemas-3.8-20120326.jar']);
    javaaddpath([xldir '/poi_library/xmlbeans-2.3.0.jar']);
    javaaddpath([xldir '/poi_library/dom4j-1.6.1.jar']);
    javaaddpath([xldir '/poi_library/stax-api-1.0.1.jar']);
end
% prepare the atlases and elec structure
atlas = {};
name = {};
elec = [];
if ~isempty(elec_mni) % mni-based atlases
    [~, ftpath]       = ft_version;
    atlas{end+1}      = ft_read_atlas([ftpath ...
      '/template/atlas/afni/TTatlas+tlrc.HEAD']); % AFNI
    name{end+1}       = 'AFNI';
    atlas{end+1}      = ft_read_atlas([ftpath ...
      '/template/atlas/aal/ROI_MNI_V4.nii']); % AAL
    name{end+1}       = 'AAL';
    brainweb = load([ftpath ...
      '/template/atlas/brainweb/brainweb_discrete.mat']);
    atlas{end+1} = brainweb.atlas; clear brainweb; % BrainWeb
    name{end+1} = 'BrainWeb';
    atlas{end+1} = ft_read_atlas([ftpath ...
      '/template/atlas/spm_anatomy/AllAreas_v18_MPM']); % JuBrain
    name{end+1}       = 'JuBrain';
    load([ftpath '/template/atlas/vtpm/vtpm.mat']);
    atlas{end+1} = vtpm; % VTPM
    name{end+1} = 'VTPM';
    atlas{end+1} = ft_read_atlas([ftpath ... % Brainnetome
        '/template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii']);
    name{end+1}       = 'Brainnetome';
    elec              = elec_mni;
end
if ~isempty(elec_nat) && ~isempty(fsdir) % freesurfer-based atlases
    atlas{end+1}      = ft_read_atlas([fsdir ...
    '/mri/aparc+aseg.mgz']); % Desikan-Killiany (+volumetric)
    atlas{end}.coordsys = 'mni';
    name{end+1}       = 'Desikan-Killiany';
    atlas{end+1}      = ft_read_atlas([fsdir ...
    '/mri/aparc.a2009s+aseg.mgz']); % Destrieux (+volumetric)
    atlas{end}.coordsys = 'mni';
    name{end+1}       = 'Destrieux';
    if isempty(elec) % elec_mni not present
        elec              = elec_nat;
    end
    elec.elecpos_fs   = elec_nat.elecpos;
end

% generate the table
table = {'Electrode','Coordinates','Discard','Epileptic', ...
  'Out of Brain','Notes','Loc Meeting',name{:}};
for e = 1:numel(elec.label) % electrode loop
    table{e+1,1} = elec.label{e}; % Electrode
    table{e+1,2} = num2str(elec.elecpos(e,:)); % Coordinates
    table{e+1,3} = 0; % Discard
    table{e+1,4} = 0; % Epileptic
    table{e+1,5} = 0; % Out of Brain
    table{e+1,6} = ''; % Notes
    table{e+1,7} = ''; % Localization Meeting
    for a = 1:numel(atlas) % atlas loop
        fprintf(['>> electrode ' elec.label{e} ', ' table{1,7+a} ...
      ' atlas <<\n'])
        cfg = [];
        if strcmp(name{a}, 'Desikan-Killiany') || ...
                  strcmp(name{a}, 'Destrieux') % freesurfer-based atlases
            cfg.roi = elec.elecpos_fs(e,:); % from elec-nat
        else
            cfg.roi = elec.elecpos(e,:); % from elec_mni
        end
        
        cfg.atlas = atlas{a};
        cfg.inputcoord = 'mni';
        cfg.output = 'label';
        cfg.maxqueryrange = 5;
        labels = ft_volumelookup(cfg, atlas{a});
        [~, indx] = max(labels.count);
        table{e+1,7+a} = char(labels.name(indx)); % anatomical label
        clear labels indx
    end % end of atlas loop
end % end of electrode loop
% write to excel file
if isunix
  xlwrite(filename, table);
else
  xlswrite(filename, table);
end
