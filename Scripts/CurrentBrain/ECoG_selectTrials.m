%This function selects a subset of specific trials based on
%behavioral/conditional parameters
%Project: ECoG_WM
%Author: D.T.
%Date: 26 September 2019

function [allTrials, filter] = ECoG_selectTrials(params, data)

%First, make sure to only consider those trials also included in the ECoG
%analyses
allTrials = data.EEG_included == 1;

%Select task (i.e., collect match/0 or collect mismatch/1)
if strcmp(params.cue, 'match')
    cue = data.cue == 0;
elseif strcmp(params.cue, 'mismatch')
    cue = data.cue == 1;
elseif strcmp(params.cue, 'all')
    cue = data.cue >= 0;
end

%Select load (i.e., load 1/1, load 2/2, load 4/4)
if strcmp(params.load, 'load1')
    load = data.load == 1;
elseif strcmp(params.load, 'load2')
    load = data.load == 2;
elseif strcmp(params.load, 'load4')
    load = data.load == 4;
elseif strcmp(params.load, 'all')
    load = data.load >= 0;
end

%Select specific probe (i.e., match/0, mismatch/1)
if strcmp(params.probe, 'match')
    probe = data.probe == 0;
elseif strcmp(params.probe, 'mismatch')
    probe = data.probe == 1;
elseif strcmp(params.probe, 'all')
    probe = data.probe >= 0;
end

%Select specific stimulus identity
if strcmp(params.id, 'id1')
    id = (data.stimA_id == 0) | (data.stimB_id == 0) | (data.stimC_id == 0) | (data.stimD_id == 0);
elseif strcmp(params.id, 'id2')
    id = (data.stimA_id == 1) | (data.stimB_id == 1) | (data.stimC_id == 1) | (data.stimD_id == 1);
elseif strcmp(params.id, 'id3')
    id = (data.stimA_id == 2) | (data.stimB_id == 2) | (data.stimC_id == 2) | (data.stimD_id == 2);  
elseif strcmp(params.id, 'id4')
    id = (data.stimA_id == 3) | (data.stimB_id == 3) | (data.stimC_id == 3) | (data.stimD_id == 3);
elseif strcmp(params.id, 'id5')
    id = (data.stimA_id == 4) | (data.stimB_id == 4) | (data.stimC_id == 4) | (data.stimD_id == 4);
elseif strcmp(params.id, 'id6')
    id = (data.stimA_id == 5) | (data.stimB_id == 5) | (data.stimC_id == 5) | (data.stimD_id == 5);
elseif strcmp(params.id, 'id7')
    id = (data.stimA_id == 6) | (data.stimB_id == 6) | (data.stimC_id == 6) | (data.stimD_id == 6);
elseif strcmp(params.id, 'id8')
    id = (data.stimA_id == 7) | (data.stimB_id == 7) | (data.stimC_id == 7) | (data.stimD_id == 7);
elseif strcmp(params.id, 'id9')
    id = (data.stimA_id == 8) | (data.stimB_id == 8) | (data.stimC_id == 8) | (data.stimD_id == 8);
elseif strcmp(params.id, 'id10')
    id = (data.stimA_id == 9) | (data.stimB_id == 9) | (data.stimC_id == 9) | (data.stimD_id == 9);
elseif strcmp(params.id, 'all')
    id = (data.stimA_id >= 0);
end

%Select specific probe identity
if strcmp(params.id, 'probe_id1')
    probe_id = (data.probe_id == 0); 
elseif strcmp(params.id, 'probe_id2')
    probe_id = (data.probe_id == 1); 
elseif strcmp(params.id, 'probe_id3')
    probe_id = (data.probe_id == 2); 
elseif strcmp(params.id, 'probe_id4')
    probe_id = (data.probe_id == 3); 
elseif strcmp(params.id, 'probe_id5')
    probe_id = (data.probe_id == 4); 
elseif strcmp(params.id, 'probe_id6')
    probe_id = (data.probe_id == 5); 
elseif strcmp(params.id, 'probe_id7')
    probe_id = (data.probe_id == 6);
elseif strcmp(params.id, 'probe_id8')
    probe_id = (data.probe_id == 7); 
elseif strcmp(params.id, 'probe_id9')
    probe_id = (data.probe_id == 8); 
elseif strcmp(params.id, 'probe_id10')
    probe_id = (data.probe_id == 9); 
elseif strcmp(params.id, 'all')
    probe_id = (data.probe_id >= 1); 
end

%Select specific response
if strcmp(params.resp, 'correct')
    resp = ismember(data.resp, [1, 3]); %this includes trials, in which a probe was collected when it should have been collected (1) and in which it was not collected when it should not have been collected (3)
elseif strcmp(params.resp, 'incorrect')
    resp = ismember(data.resp, [2, 4]);
elseif strcmp(params.resp, 'all')
    resp = ismember(data.resp, [1 : 4]);
end

%Select all compatible trials
filter = allTrials & cue & load & probe & id & probe_id & resp; 
end