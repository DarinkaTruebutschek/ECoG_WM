%This is the main script to subsample trials based on different criteria
%Project: ECoG_WM
%Author: D.T.
%Date: 22 July 2019

clear all;
close all;
clc;

%% Add relevant paths
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'}; %included subnips

condition = 'indItems_task';

%% Load data and subsample (i.e., within each subject, each condition should have the same number of trials)
for subi = 1 : length(subnips)
    
    %Load data
    load([res_path subnips{subi} '/' subnips{subi} '_erp_100.mat']);
    
    %Load behavioral data
    load([behavior_path subnips{subi} '_memory_behavior_combined.mat']);
    
    %Identify trial numbers per instance of identity
    for identi = 1 : 10
        n_trials(identi) = sum((data_mem.stimA_id == identi-1) | ...
            (data_mem.stimB_id == identi-1) | (data_mem.stimC_id == identi-1) | ...
            (data_mem.stimD_id == identi-1));   
    end
    
    %Select trials to keep
    selIndex = [];
    n_identities = cell(1, 10);
    n_identities(:) = {zeros(1)};
    
    for triali = 1 : size(data_mem, 1)
        tmp = [];
        
        %First, check which identities still need to be added
        for identi = 1 : 10
            if n_identities{identi} <= min(n_trials)
                tmp(end+1) = identi;
            end
        end
        
        %Then, check whether the current trial can be added and update the identity count
        if ismember(data_mem.stimA_id(triali), tmp-1) & ismember(data_mem.stimB_id(triali), tmp-1) & ...
                ismember(data_mem.stimC_id(triali), tmp-1) & ismember(data_mem.stimD_id(triali), tmp-1)
            for identi = tmp
                if data_mem.stimA_id(triali) == identi-1
                    n_identities{identi} = n_identities{identi}+1;
                end
            
                if data_mem.stimB_id(triali) == identi-1
                    n_identities{identi} = n_identities{identi}+1;
                end
            
                if data_mem.stimC_id(triali) == identi-1
                    n_identities{identi} = n_identities{identi}+1;
                end
            
                if data_mem.stimD_id(triali) == identi-1
                    n_identities{identi} = n_identities{identi}+1;
                end
            end
     
            %Last, add respective trial 
            selIndex(end+1, 1) = triali;
        end
    end
        
       %Check if any of the cells has already  reached  the minimum number
       %of instances
%        if (n_identities{1} < min(n_trials)) & (n_identities{2} < min(n_trials)) & ...
%                (n_identities{3} < min(n_trials)) & (n_identities{4} < min(n_trials)) & ...
%                (n_identities{5} < min(n_trials)) & (n_identities{6} < min(n_trials)) & ...
%                (n_identities{7} < min(n_trials)) & (n_identities{8} < min(n_trials)) & ...
%                (n_identities{9} < min(n_trials)) & (n_identities{10} < min(n_trials))
%            selIndex(end+1, 1) = triali;
%        end      


    
%     %Select random number of trials to keep
%     for identi = 1 : 10
%         [index{identi}, ~] = find((data_mem.stimA_id == identi-1) | ...
%             (data_mem.stimB_id == identi-1) | (data_mem.stimC_id == identi-1) | ...
%             (data_mem.stimD_id == identi-1));
%  
%         [~, tmp] = min(n_trials);
%         
%         if identi ~= tmp
%             selIndex{identi} = randperm(length(index{identi}));
%             selIndex{identi} = sort(index{identi}(selIndex{identi}(1 : min(n_trials))));
%         else
%             selIndex{identi} = index{identi};
%         end
%     end
%     
    %Subselect behavioral data
    data_mem_tmp = data_mem(selIndex, 1:21);
    
    %Sanity check: Confirm that each identity is displayed an equal number
    %of times
    for identi = 1 : 10
        n_trials_tmp(identi) = sum((data_mem_tmp.stimA_id == identi-1) | ...
            (data_mem_tmp.stimB_id == identi-1) | (data_mem_tmp.stimC_id == identi-1) | ...
            (data_mem_tmp.stimD_id == identi-1));   
    end
end