%This function extracts the relevant behavioral data from .json files and saves them in an accessible matlab matrix.
%Project: ECoG_WM
%Author: D.T.
%Date: 13 March 2019

function [data_mem, data_reward] = ECoG_getBehavior(data_dir)

%% Determine number of sessions
cd(data_dir);
content = dir('*.json');
num_sessions = size(content, 1);

session = cell(1, num_sessions);

%% Load data
for sessi = 1 : num_sessions
    disp (['Getting session ' num2str(sessi)]);
    session{sessi} = loadjson([data_dir content(sessi).name]);
end

%% Extract data for both the memory task and the reward learning task
trialinfo_mem = [];
trialinfo_reward = [];

trialnum_mem = 1;
trialnum_reward = 1;

blocknum_mem = 0; %there are 21 trials in 1 block, comprised of a memory and a reward round
blocknum_reward = 0; 

for sessi = 1 : num_sessions
    for triali = 1 : numel(session{sessi})
        
        if isfield(session{sessi}{triali}, 'trial') %other cells correspond to events
            
            if strcmp(session{sessi}{triali}.trial, 'memory')
                
                trialinfo_mem(trialnum_mem,1 : 16) = nan(1,16);
                
                trialinfo_mem(trialnum_mem, 1) = sessi; %index for session
                trialinfo_mem(trialnum_mem, 2) = trialnum_mem; %index for trial number
                trialinfo_mem(trialnum_mem, 3) = blocknum_mem; %index for block number
                
                trialinfo_mem(trialnum_mem, 4) = session{sessi}{triali}.isCollectMismatch; %rule cue: collect match(0) or collect mismatch (1)
                trialinfo_mem(trialnum_mem, 5) = session{sessi}{triali}.isProbeMismatch; %probe identity: match (0) or mismatch (1)
                trialinfo_mem(trialnum_mem, 6) = session{sessi}{triali}.shouldCollect; %expected response: collect (1) o not (0)
                trialinfo_mem(trialnum_mem, 7) = session{sessi}{triali}.memoryLoad; %1, 2, or 4
                
                trialinfo_mem(trialnum_mem, 8 : 8 + size(session{sessi}{triali}.stimInds, 2) - 1) = session{sessi}{triali}.stimInds; %identity of memory items 
                trialinfo_mem(trialnum_mem, 12) = session{sessi}{triali}.probeStimInd; %identity of probe
                trialinfo_mem(trialnum_mem, 13) = session{sessi}{triali}.responseResult; %response: 1 = correctly collectd match, 2 = shoulCollect false, but collected, 3 = reject match, 4 = did not collect mismatch
                trialinfo_mem(trialnum_mem, 14) = session{sessi}{triali}.reactionTime/1000; %RT
                trialinfo_mem(trialnum_mem, 17 : 17 + size(session{sessi}{triali}.stimAngles, 2) - 1) = session{sessi}{triali}.stimAngles; %locations of memory stimuli on screen
                
                %Check RT
                if (session{sessi}{triali}.reactionTime/1000 < .01) || (session{sessi}{triali}.reactionTime/1000 > 10)
                    trialinfo_mem(trialnum_mem, 15) = 0;
                else
                    trialinfo_mem(trialnum_mem, 15) = 1; 
                end
                
                %Check time
                timing = round(diff(cell2mat(struct2cell(session{sessi}{triali}.timestamps))), -1); %extract duration of individual events
                checkTime(trialnum_mem, :) = diff(cell2mat(struct2cell(session{sessi}{triali}.timestamps))); %this is just so that I can directly compare the behavioral output with the imaging data
                
                if ismember(timing(1), [480 : 1 : 520]) %fixation: 500 ms
                   tmp(1) = 1;
                end
                
                                
                if ismember(timing(2), [480 : 1 : 520]) %rule cue: 500 ms
                   tmp(2) = 1;
                end
                
                                
                if ismember(timing(3), [980 : 1 : 1020]) %delay 1: 1000 ms
                   tmp(3) = 1;
                end
                
                                
                if ismember(timing(4), [980 : 1 : 1020]) %memory array: 1000 ms
                   tmp(4) = 1;
                end
                
                if ismember(timing(5), [1980 : 1 : 2020]) %delay 2: 2000 ms
                   tmp(5) = 1;
                end

                if sum(tmp) == 5
                    trialinfo_mem(trialnum_mem, 16) = 1;
                else
                    trialinfo_mem(trialnum_mem, 16) = 0;
                    disp(['Incorrect timing on trial ' num2str(trialnum_mem)]);
                end
                
                %Update trial count for memory condition
                trialnum_mem = trialnum_mem + 1; 
            
            elseif strcmp(session{sessi}{triali}.trial, 'bonus') %reward round
 
                trialinfo_reward(trialnum_reward,1 : 22) = nan(1,22);
                       
                trialinfo_reward(trialnum_reward, 1) = sessi; %index for session
                trialinfo_reward(trialnum_reward, 2) = trialnum_reward; %index for trial number
                trialinfo_reward(trialnum_reward, 3) = blocknum_reward; %index for block number
                
                trialinfo_reward(trialnum_reward, 4 : 4 + size(session{sessi}{triali}.stimInds, 2) - 1) = session{sessi}{triali}.stimInds; %identity of stimuli presented
                trialinfo_reward(trialnum_reward, 7 : 7 + size(session{sessi}{triali}.rewardProbs, 2) - 1) = session{sessi}{triali}.rewardProbs; %reward probabilities associated with each of the stimuli shown
                trialinfo_reward(trialnum_reward, 10 : 10 + size(session{sessi}{triali}.rewardPotential, 2) - 1) = session{sessi}{triali}.rewardPotential; %value associated with each identity
                trialinfo_reward(trialnum_reward, 13 : 13 + size(session{sessi}{triali}.rewardLevels, 2) - 1) = session{sessi}{triali}.rewardLevels; 
               
                trialinfo_reward(trialnum_reward, 16) = session{sessi}{triali}.reactionTime/1000; %RT
                trialinfo_reward(trialnum_reward, 17) = session{sessi}{triali}.chosenStim; %identity of chosen stimulus
                
                trialinfo_reward(trialnum_reward, 18 : 18 + size(session{sessi}{triali}.stimX, 2) - 1) = session{sessi}{triali}.stimX; %x position of stimuli
                trialinfo_reward(trialnum_reward, 19 : 19 + size(session{sessi}{triali}.stimY, 2) - 1) = session{sessi}{triali}.stimY; %y position of stimuli
                
                %Check RT
                if (session{sessi}{triali}.reactionTime/1000 < .01) || (session{sessi}{triali}.reactionTime/1000 > 10)
                    trialinfo_reward(trialnum_reward, 22) = 0;
                else
                    trialinfo_reward(trialnum_reward, 22) = 1; 
                end

                %Update trial count for reward condition
                trialnum_reward = trialnum_reward + 1; 
            end
            
        elseif isfield(session{sessi}{triali}, 'event')
            if strcmp('roundStart', session{sessi}{triali}.event) && strcmp('memory', session{sessi}{triali}.roundType)
                blocknum_mem = blocknum_mem + 1; %update block count
            elseif strcmp('roundStart', session{sessi}{triali}.event) && strcmp('bonus', session{sessi}{triali}.roundType)
                blocknum_reward = blocknum_reward + 1; %update block count
            end
        end 
    end
end

%% Organize into table

%Memory task
session_id = trialinfo_mem(:, 1);
trial_id = trialinfo_mem(:, 2); 
block_id = trialinfo_mem(:, 3);
cue = trialinfo_mem(:, 4); %0 = collect match, 1 = collect mismatch
probe = trialinfo_mem(:, 5); %0 = match, 1 = mismatch
correctResp = trialinfo_mem(:, 6); %0 = do not collect, 1 = collect
load = trialinfo_mem(:, 7); %memory load: 1, 2, or 4
stimA_id = trialinfo_mem(:, 8); %stim ID at pos A
stimB_id = trialinfo_mem(:, 9); %stim ID at pos B
stimC_id = trialinfo_mem(:, 10); %stim ID at pos C
stimD_id = trialinfo_mem(:, 11); %stim ID at pos D
stimA_angle = trialinfo_mem(:, 17); %stim ID at pos A
stimB_angle = trialinfo_mem(:, 18); %stim ID at pos B
stimC_angle = trialinfo_mem(:, 19); %stim ID at pos C
stimD_angle = trialinfo_mem(:, 20); %stim ID at pos D
probe_id = trialinfo_mem(:, 12); %specific identity of probe
resp = trialinfo_mem(:, 13); %0 = not collected, 1 = collected
RT = trialinfo_mem(:, 14);
RT_included = trialinfo_mem(:, 15); %marked trials with very fast or very slow responses
timing = trialinfo_mem(:, 16); %marked trials with deviating timing

data_mem =  table(session_id, trial_id, block_id, cue, probe, correctResp, load, ...
    stimA_id, stimB_id, stimC_id, stimD_id,  stimA_angle, stimB_angle, stimC_angle, stimD_angle, probe_id, resp, RT, RT_included, timing);

%Reward task
session_id = trialinfo_reward(:, 1);
trial_id = trialinfo_reward(:, 2); 
block_id = trialinfo_reward(:, 3);
stimA_id = trialinfo_reward(:, 4); 
stimB_id = trialinfo_reward(:, 5); 
stimC_id = trialinfo_reward(:, 6);
probaA = trialinfo_reward(:, 7); 
probaB = trialinfo_reward(:, 8); 
probaC = trialinfo_reward(:, 9); 
rewardA = trialinfo_reward(:, 10); 
rewardB = trialinfo_reward(:, 11); 
rewardC = trialinfo_reward(:, 12); 
rewardLevA = trialinfo_reward(:, 13);
rewardLevB = trialinfo_reward(:, 14);
rewardLevC = trialinfo_reward(:, 15);
RT = trialinfo_reward(:, 16);
subSelection = trialinfo_reward(:, 17); 
xPos = trialinfo_reward(:, 18); 
yPosA = trialinfo_reward(:, 19); 
yPosB = trialinfo_reward(:, 20); 
yPosC = trialinfo_reward(:, 21); 
RT_included = trialinfo_reward(:, 22); %marked trials with very fast or very slow responses

data_reward =  table(session_id, trial_id, block_id, stimA_id, stimB_id, stimC_id, probaA, probaB, probaC, ...
    rewardA, rewardB, rewardC, rewardLevA, rewardLevB, rewardLevC, RT, subSelection, xPos, yPosA, yPosB, yPosC, RT_included);

cd ..;
cd ..; 
end
