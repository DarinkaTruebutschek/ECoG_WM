%This function checks the trigger values obtained from the iEEG data and 
%compares them with the behavioral data.
%Project: ECoG_WM
%Author: Darinka Truebutschek
%Date: 9 May 2019

function [alltrig, alltimes, durations, data_mem] = ECoG_checkTriggers(values, samples, sessi, data_mem, subject, sampfreq)

alltrig  = []; %trial x trigger value matrix
alltimes = []; %trial x trigger samples matrix

%First, identify the beginning of each trial (i.e., precue baseline, corresponding to value == 1) 
alltimes = samples(values == 1)';

%Next, get all triggers between each pair of precue baseline triggers
for triali = 1 : size(alltimes, 1)
    if triali < size(alltimes, 1)
        tmp1 = find(samples == alltimes(triali));
        tmp2 = find(samples == alltimes(triali + 1));
        tmp3 = values(tmp1 : tmp2-1); 
        
        %Check if the ordering of events makes sense
        if length(tmp3) >= 7
            if (tmp3(1) == 1) && (ismember(tmp3(2), [2, 3])) && (tmp3(3) == 4) ...
                    && (ismember(tmp3(4), [10 : 12])) && (tmp3(5) == 5) && (ismember(tmp3(6), [20 : 39])) ...
                    && (ismember(tmp3(7), [7, 8]))
                alltrig(triali, 1 : 7) = tmp3(1 : 7);
                alltimes(triali, 1 : 7) = samples(tmp1 : tmp1+6);
            else
                display(['Incorrect trigger sequence for trial: ' num2str(triali)]);
            end
        else
            alltrig(triali, 1 : 7) = nan;
            alltimes(triali, 1 : 7) = nan;
            display(['Incorrect number of triggers for trial: ' num2str(triali)]);
        end
    else
        tmp1 = find(samples == alltimes(triali));
        try
            tmp3 = values(tmp1 : tmp1+6); 
        catch
            if strcmp(subject, 'HS')
                tmp3 = values(tmp1 : tmp1+4); %this statement had to be added in case there were not enough triggers for the last trial (e.g., HS/session1)
            elseif strcmp(subject, 'HL')
                tmp3 = values(tmp1 : tmp1+0);
            end
        end
        %Check if the ordering of events makes sense
        if length(tmp3) >= 7
            if (tmp3(1) == 1) && (ismember(tmp3(2), [2, 3])) && (tmp3(3) == 4) ...
                    && (ismember(tmp3(4), [10 : 12])) && (tmp3(5) == 5) && (ismember(tmp3(6), [20 : 39])) ...
                    && (ismember(tmp3(7), [7, 8]))
                alltrig(triali, 1 : 7) = tmp3(1 : 7);
                alltimes(triali, 1 : 7) = samples(tmp1 : tmp1+6);
            else
                display(['Incorrect trigger sequence for trial: ' num2str(triali)]);
            end
        else
            alltrig(triali, 1 : 7) = nan;
            alltimes(triali, 1 : 7) = nan;
            display(['Incorrect number of triggers for trial: ' num2str(triali)]);
        end
    end
end

%Exclude all trials with incorrect trigger information
[tmp, ~] = find(~isnan(alltrig(:, 1)));
tmp1 = alltrig(tmp, :);
tmp2 = alltimes(tmp, :);

alltrig = tmp1;
alltimes = tmp2;

%Then, check that timing of individual events is appropriate
for triali = 1 : size (alltrig, 1)
    durations(triali, :) = diff(alltimes(triali, :));
end

my_title = {'Precue baseline', 'Cue', 'Delay 1', 'Memory array', 'Delay 2', 'RT'};
figure;
for eventi = 1 : size(durations, 2)
    subplot(2, 3, eventi);
    hist(durations(:, eventi) / sampfreq, 30)
    title(my_title{eventi});
    xlabel('Duration (s)');
end

%Compare with behavioral results to ensure compatability
cue = data_mem.cue(data_mem.session_id == sessi);
cue(cue == 0) = 2;
cue(cue == 1) = 3;

load = data_mem.load(data_mem.session_id == sessi);
load(load == 1) = 10;
load(load == 2) = 11;
load(load == 4) = 12;

%First, check whether matrix dimensions agree
if size(cue, 1) == size(alltrig, 1)
    if (sum(alltrig(:, 2) - cue) && sum(alltrig(:, 4) - load)) ~= 0
        display('There is a mismatch between behavioral and iEEG data.');
    else
        display('No mismatch detected.');
    end
    
    clear ('tmp', 'tmp1', 'tmp2', 'tmp3');
else
    clear ('tmp', 'tmp1', 'tmp2', 'tmp3');
    
    disp('Mismatch in number of trials between EEG and behavioral session. Trying to find match!');
    
    %We will then attempt to match the triggers based on RT
    tmp = durations(:, 6);
    tmp = tmp ./ sampfreq;
    
    tmp1 = data_mem.RT(data_mem.session_id == sessi);
    
    if strcmp(subject, 'MKL') && (sessi == 1)
        %Update data_mem
        session_id = ones(80, 1);
        trial_id = [1 : 1 : 80]';
        block_id = nan(80, 1);
        cue = nan(80, 1);
        probe = nan(80, 1);
        correctResp = nan(80, 1);
        load = nan(80, 1);
        stimA_id = nan(80, 1);
        stimB_id = nan(80, 1);
        stimC_id = nan(80, 1);
        stimD_id = nan(80, 1);
        probe_id = nan(80, 1);
        resp = nan(80, 1);
        RT = nan(80, 1);
        RT_included = nan(80, 1);
        timing = nan(80, 1);
        
        table_tmp = table(session_id, trial_id, block_id, cue, probe, correctResp, load, ...
            stimA_id, stimB_id, stimC_id, stimD_id, probe_id, resp, RT, RT_included, timing);
        data_mem_new = [table_tmp; data_mem];
        
        %Recheck to see if this is correct
        cue = data_mem_new.cue(1 : 618);
        cue(cue == 0) = 2;
        cue(cue == 1) = 3;

        load = data_mem_new.load(1 : 618);
        load(load == 1) = 10;
        load(load == 2) = 11;
        load(load == 4) = 12;
        
        if sum(alltrig(81 : end, 2) - cue(81 : end)) && sum(alltrig(81 : end, 4) - load(81 : end)) ~= 0
             display('There is a mismatch between behavioral and iEEG data.');
        else
            display('No mismatch detected.');
        end
        
        data_mem_new.trial_id = [1 : 658]';
        data_mem_new.session_id(1 : 618) = 1;
        
        data_mem = data_mem_new;
    elseif strcmp(subject, 'HS') && (sessi == 1)
        alltrig_new = [];
        alltrig_new(1 : 4, 1 : 7) = nan;
        alltrig_new = [alltrig_new; alltrig];
        alltrig = alltrig_new;
        
        alltimes_new = [];
        alltimes_new(1 : 4, 1 : 7) = nan;
        alltimes_new = [alltimes_new; alltimes];
        alltimes = alltimes_new;
        
        %Recheck
        if (sum(alltrig(5 : end, 2) - cue(5: end)) && sum(alltrig(5 : end, 4) - load(5 : end))) ~= 0
            display('There is a mismatch between behavioral and iEEG data.');
        else
            display('No mismatch detected.');
        end
        
        alltrig = alltrig(5 : end, :);
        alltimes = alltimes(5 : end, :);
    elseif strcmp(subject, 'MG') && (sessi == 3)
        if (sum(alltrig(:, 2) - cue(285 :298)) && sum(alltrig(:, 4) - load(285 :298))) ~= 0
            display('There is a mismatch between behavioral and iEEG data.');
        else
            display('No mismatch detected.');
        end
    
        clear ('tmp', 'tmp1', 'tmp2', 'tmp3');
        
        %Add info to behavioral file from first, second, and third session
        data_mem.EEG_included(1 : 800) = nan; %first and second session
        data_mem.EEG_included(801 : 1084) = 0; %these trials from the third session are missing
        data_mem.EEG_included(1085 : 1098) = nan; %these trials from session 3 could potentially be included
        data_mem.EEG_included(1099 : end) = 0; %these trials from session 3 are definitely missing
    elseif strcmp(subject, 'KR') && (sessi == 1)
        alltrig_new = alltrig;
        alltimes_new = alltimes;
        
        alltrig_new = alltrig_new(3 : end, :);
        alltimes_new = alltimes_new(3 : end, :);
        
        alltrig = alltrig_new;
        alltimes = alltimes_new;
        
        %Recheck
        if (sum(alltrig(:, 2) - cue) && sum(alltrig(:, 4) - load)) ~= 0
            display('There is a mismatch between behavioral and iEEG data.');
        else
            display('No mismatch detected.');
        end
    elseif strcmp(subject, 'WS') && (sessi == 2)
        alltrig_new = alltrig;
        alltimes_new = alltimes;
        
        alltrig_new = alltrig_new(2 : end, :);
        alltimes_new = alltimes_new(2 : end, :);
        
        alltrig = alltrig_new;
        alltimes = alltimes_new;
        
        %Recheck
        if (sum(alltrig(:, 2) - cue) && sum(alltrig(:, 4) - load)) ~= 0
            display('There is a mismatch between behavioral and iEEG data.');
        else
            display('No mismatch detected.');
        end
    end 
end

%For some subjects, the timing during the EEG session suddenly changed,
%such that we need to exclude these trials
if strcmp(subject, 'HS') && sessi == 2
    correct_timing = durations(:, 1) < 700;
    
    alltrig(103 : end, :) = [];
    alltimes(103 : end, :) = [];
    
    %Add info to behavioral file from first and second session
    data_mem.EEG_included(1 : 4) = 0;
    data_mem.EEG_included(5 : 139) = nan;
    data_mem.EEG_included(140 : 241) = nan;
    data_mem.EEG_included(242 : end) = 0;
    
    %Recheck timing
    my_title = {'Precue baseline', 'Cue', 'Delay 1', 'Memory array', 'Delay 2', 'RT'};
    figure;
    for eventi = 1 : size(durations(1 : 102, :), 2)
        subplot(2, 3, eventi);
        hist(durations(1 : 102, eventi) / 1000, 20)
        title(my_title{eventi});
        xlabel('Duration (s)');
    end
elseif strcmp(subject, 'HL') && sessi == 2
    alltrig(1 : end, :) = [];
    alltimes(1 : end, :) = [];
    
    %Add info to behavioral file from first and second session
    data_mem.EEG_included(1 : 400) = nan;
    data_mem.EEG_included(401 : end) = 0;

    %Recheck timing
    my_title = {'Precue baseline', 'Cue', 'Delay 1', 'Memory array', 'Delay 2', 'RT'};
    figure;
    for eventi = 1 : size(durations(1 : 102, :), 2)
        subplot(2, 3, eventi);
        hist(durations(1 : 102, eventi) / 1000, 20)
        title(my_title{eventi});
        xlabel('Duration (s)');
    end
end
end

