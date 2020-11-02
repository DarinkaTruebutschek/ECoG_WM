%This is the main script to run the entire behavioral analysis pipeline.
%Project: ECoG_WM
%Author: D.T.
%Date: 13 March 2019

clear all; 
close all;
clc;

%% Add relevant paths
dat_path = '/media/darinka/Data0/iEEG/';
res_path = '/media/darinka/Data0/iEEG/Results/Behavior/';
script_path = '/media/darinka/Data0/iEEG/ECoG_WM/Scripts/CurrentBehavior/';
toolbox_path = '/media/darinka/Data0/iEEG/ECoG_WM/Scripts/Toolboxes/';

addpath(script_path);
addpath(toolbox_path);

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};
%subnips = {'CD'};
condition = 'memory';

%% Extract behavioral data from original files and save as a .mat file
for subi = 1 : length(subnips)
    
    res_filename_mem = [subnips{subi} '_memory_behavior_withLocs.mat'];
    res_filename_reward = [subnips{subi} '_reward_behavior.mat'];
    
%     %Check whether data have already been preprocessed, if so, skip this
%     %subject
%     if exist([res_path res_filename_mem])
%         continue
%     end
    
    disp(['Preprocessing behavioral data for subject: ' subnips{subi}]);
    
    %Specify exact filenames to be loaded for each inividual subject
    switch char(subnips{subi})
        case 'MKL'
            dirname = [dat_path subnips{subi} '/logs/'];
        case 'EG_I'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'HS'
            dirname = [dat_path subnips{subi} '/logs/'];
        case 'MG'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'KR'
            dirname = [dat_path subnips{subi} '/logs/'];
        case 'WS'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'KJ_I'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'LJ'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'AS'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'SB'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'HL'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'AP'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'AK_001'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'MV'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'CD'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'SM'
            dirname = [dat_path subnips{subi} '/Explogs/'];
        case 'SB_Sept19'
            dirname = [dat_path subnips{subi} '/Explogs/'];
    end

    [data_mem, data_reward] = ECoG_getBehavior(dirname);
    
    %Save data
    save([res_path res_filename_mem], 'data_mem');
    save([res_path res_filename_reward], 'data_reward');  
end

%% Get general idea of number of trials/condition (individual subjects)
for subi = 1 : length(subnips)
    
    load([res_path subnips{subi} '_' condition '_behavior.mat']);
    
    no_rule{subi} = ECoG_getTrialCount([data_mem.cue, data_mem.EEG_included], 'rule'); %get # of trials per rule condition
    no_load{subi} = ECoG_getTrialCount([data_mem.load, data_mem.EEG_included], 'load'); %get # of trials per load condition
    no_stimID{subi} = ECoG_getTrialCount([data_mem.stimA_id, data_mem.stimB_id, data_mem.stimC_id, data_mem.stimD_id, data_mem.EEG_included], 'stimID'); %get # of trials a given stimulus ID was shown (collapsed across load)
    no_rule_stimID{subi} = ECoG_getTrialCount([data_mem.cue, data_mem.stimA_id, data_mem.stimB_id, data_mem.stimC_id, data_mem.stimD_id, data_mem.EEG_included], 'rule_stimID'); %get # of trials a given stimulus ID was shown per rule condition
    
    %Sanity checks
    totalTrials{subi} = sum(data_mem.EEG_included == 1);
    
    if sum(no_rule{subi}) ~= totalTrials{subi}
        display('Error! Incorrect trial count for cue condition.');
    end
    
    if sum(no_load{subi}) ~= totalTrials{subi}
        display('Error! Incorrect trial count for load condition.');
    end
    
    %Plot inividual data
    plotPrettyBar(no_rule{subi}, cbrewer('qual', 'Set1', 2), [], [], {'', '# trials'}, {'', 'Rule1', 'Rule2', ''}, 0);
    printfig(gcf, [0 0 5 8], [res_path subnips{subi} '_NoTrials_Rule.tiff']);
    
    plotPrettyBar(no_load{subi}, cbrewer('seq', 'Greens', 3), [], [], {'', '# trials'}, {'', 'Load1', 'Load2', 'Load3', ''}, 0);
    printfig(gcf, [0 0 6 8], [res_path subnips{subi} '_NoTrials_Load.tiff']);
    
    plotPrettyBar(no_rule_stimID{subi}(1, :), cbrewer('seq', 'OrRd', 10), [], [], {'', '# trials'}, {'', 'Stim1', 'Stim2', 'Stim3', 'Stim4', 'Stim5', ...
        'Stim6', 'Stim7', 'Stim8', 'Stim9', 'Stim10', ''}, 0);
    printfig(gcf, [0 0 15 8], [res_path subnips{subi} '_NoTrials_StimxRule_1.tiff']);
    
    plotPrettyBar(no_rule_stimID{subi}(2, :), cbrewer('seq', 'Blues', 10), [], [], {'', '# trials'}, {'', 'Stim1', 'Stim2', 'Stim3', 'Stim4', 'Stim5', ...
        'Stim6', 'Stim7', 'Stim8', 'Stim9', 'Stim10', ''}, 0);
    printfig(gcf, [0 0 15 8], [res_path subnips{subi} '_NoTrials_StimxRule_2.tiff']);
    
    close all;
    pause;
end

%% Get general idea of number of trials/condition (group)

%Rule
no_rule_mat = cell2mat(no_rule(:));
plotPrettyNotBoxPlot(no_rule_mat, 'sdline', cbrewer('qual', 'Set1', 2), .5, [0 2], [0 400], {'', '# trials'}, {'', 'Rule1', 'Rule2', ''});
printfig(gcf, [0 0 6 8], [res_path 'Group_NoTrials_Rule.tiff']);

%Load
no_load_mat = cell2mat(no_load(:));
plotPrettyNotBoxPlot(no_load_mat, 'sdline', cbrewer('seq', 'Greens', 3), .8, [0 3], [0 280], {'', '# trials'}, {'', 'Load1', 'Load2', 'Load3', ''});
printfig(gcf, [0 0 6 8], [res_path 'Group_NoTrials_Load.tiff']);

%Rule1xStim 
for subi = 1 : length(subnips)
    no_rule_stimID_mat(subi, :) = no_rule_stimID{subi}(1, :);
end
plotPrettyNotBoxPlot(no_rule_stimID_mat, 'sdline', cbrewer('seq', 'OrRd', 10), 1, [0 10], [0 110], {'', '# trials'}, {'', 'Stim1', 'Stim2', 'Stim3', 'Stim4', 'Stim5', ...
        'Stim6', 'Stim7', 'Stim8', 'Stim9', 'Stim10', ''});
printfig(gcf, [0 0 15 8], [res_path 'Group_NoTrials_StimxRule_1.tiff']);

%Rule2xStim 
for subi = 1 : length(subnips)
    no_rule_stimID_mat(subi, :) = no_rule_stimID{subi}(2, :);
end
plotPrettyNotBoxPlot(no_rule_stimID_mat, 'sdline', cbrewer('seq', 'Blues', 10), 1, [0 10], [0 110], {'', '# trials'}, {'', 'Stim1', 'Stim2', 'Stim3', 'Stim4', 'Stim5', ...
        'Stim6', 'Stim7', 'Stim8', 'Stim9', 'Stim10', ''});
printfig(gcf, [0 0 15 8], [res_path 'Group_NoTrials_StimxRule_2.tiff']);

%% Task rule effect (accuracy/RT as a function of task rule)
for subi = 1 : length(subnips)
    
    load([res_path subnips{subi} '_' condition '_behavior.mat']);
    
    %Rule = collect match, probe = match (possible responses: 1, 4)
    tmp = (data_mem.cue == 0 & data_mem.probe == 0 & data_mem.resp == 1 & data_mem.EEG_included == 1); %correctly collected match
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.cue == 0 & data_mem.probe == 0 & data_mem.resp ~= 1 & data_mem.EEG_included == 1));
    accuracy(subi, 1) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 1) = median(data_mem.RT(tmp));
    
    %Rule = collect match, probe = mismatch (possible responses: 2, 3)
    tmp = (data_mem.cue == 0 & data_mem.probe == 1 & data_mem.resp == 3 & data_mem.EEG_included == 1); %correctly rejected mismatch
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.cue == 0 & data_mem.probe == 1 & data_mem.resp ~= 3 & data_mem.EEG_included == 1));
    accuracy(subi, 2) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 2) = median(data_mem.RT(tmp));
    
    %Rule = collect mismatch, probe = mismatch (possible responses: 1, 4)
    tmp = (data_mem.cue == 1 & data_mem.probe == 1 & data_mem.resp == 1 &  data_mem.EEG_included == 1); %correctly collected mismatch
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.cue == 1 & data_mem.probe == 1 & data_mem.resp ~= 1 & data_mem.EEG_included == 1));
    accuracy(subi, 3) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 3) = median(data_mem.RT(tmp));
    
    %Rule = collect mismatch, probe = match (possible responses: 2, 3)
    tmp = (data_mem.cue == 1 & data_mem.probe == 0 & data_mem.resp == 3 & data_mem.EEG_included == 1); %correctly rejected match
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.cue == 1 & data_mem.probe == 0 & data_mem.resp ~= 3 & data_mem.EEG_included == 1));
    accuracy(subi, 4) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 4)= median(data_mem.RT(tmp));
end   

%Prepare data for plotting
acc2plot = num2cell(accuracy', 2);
rt2plot = num2cell(rt', 2);
data2plot = {acc2plot, rt2plot};

%Initialize important variables for plotting
%[cb] = cbrewer('qual', 'Set3', 12, 'pchip');
[cb] = cbrewer('div', 'RdBu', 12, 'pchip');

cl(1, :) = cb(2, :);

%Plot
for figi = 1 : 2
    
    figure;
    my_handle = rm_raincloud(data2plot{figi}, cl, 0, 'ks', [], 'median');

    %Prettify
    %Change color of individual plots
    my_handle.s{1}.SizeData = 50;
    my_handle.m(1).MarkerEdgeColor = 'none';

    my_handle.p{2}.FaceColor = cb(3, :);
    my_handle.s{2}.Marker = 'o';
    my_handle.s{2}.MarkerFaceColor = cb(3, :);
    my_handle.s{2}.SizeData = 50;
    my_handle.m(2).MarkerFaceColor = cb(3, :);
    my_handle.m(2).MarkerEdgeColor = 'none';

    my_handle.p{3}.FaceColor = cb(11, :);
    my_handle.s{3}.Marker = 'o';
    my_handle.s{3}.MarkerFaceColor = cb(11, :);
    my_handle.s{3}.SizeData = 50;
    my_handle.m(3).MarkerFaceColor = cb(11, :);
    my_handle.m(3).MarkerEdgeColor = 'none';

    my_handle.p{4}.FaceColor = cb(10, :);
    my_handle.s{4}.Marker = 'o';
    my_handle.s{4}.MarkerFaceColor = cb(10, :);
    my_handle.s{4}.SizeData = 50;
    my_handle.m(4).MarkerFaceColor = cb(10, :);
    my_handle.m(4).MarkerEdgeColor = 'none';

    %Remove line connecting dots
    my_handle.l(1).Color = 'none';
    my_handle.l(2).Color = 'none';
    my_handle.l(3).Color = 'none';
    
    if figi == 1
        %Fix axes
        set(gca, 'XLim', [0, 1.2], 'XTick', [0, 0.5, 1.0, 1.2], 'XTickLabel', {'0', '50', '100', ' '}, ...
            'YTickLabel', {'Reject match', 'Collect mismatch', 'Reject mismatch', 'Collect match'}); %axes have been flipped for the plots, so labels need to be reversed as well

        %Plot chance
        hold on;
        %plot([-100000 : 0.1 : 100000] .* 0.5, 'k--');
        line([0.5 0.5], [-5 35], 'color','k','linestyle',':');

        printfig(gcf, [0 0 20 8], [res_path 'Group_Accuracy_TaskRuleEffect.tiff']);
    elseif figi == 2
        set(gca, 'XLim', [-1, 5], 'XTick', [0, 1, 2, 3, 4, 5], 'XTickLabel', {'0', '1', '2', '3', '4', '5'}, ...
            'YTickLabel', {'Reject match', 'Collect mismatch', 'Reject mismatch', 'Collect match'}); %axes have been flipped for the plots, so labels need to be reversed as well
        printfig(gcf, [0 0 20 8], [res_path 'Group_RT_TaskRuleEffect.tiff']);
    end
end
%% Load effect (accuracy/RT as a function of load)
clear ('acc2plot', 'accuracy', 'rt', 'rt2plot', 'data2plot'); 
for subi = 1 : length(subnips)
    
    load([res_path subnips{subi} '_' condition '_behavior.mat']);
    
    %Load = 1
    tmp = (data_mem.load == 1 & ismember(data_mem.resp, [1, 3]) & data_mem.EEG_included == 1); %correctly responded load 1
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 1 & ~ismember(data_mem.resp, [1, 3]) & data_mem.EEG_included == 1));
    accuracy(subi, 1) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 1) = median(data_mem.RT(tmp));
    
    %Load = 2
    tmp = (data_mem.load == 2 & ismember(data_mem.resp, [1, 3]) & data_mem.EEG_included == 1); %correctly responded load 2
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 2 & ~ismember(data_mem.resp, [1, 3]) & data_mem.EEG_included == 1));
    accuracy(subi, 2) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 2) = median(data_mem.RT(tmp));
    
    %Load = 3
    tmp = (data_mem.load == 4 & ismember(data_mem.resp, [1, 3]) & data_mem.EEG_included == 1); %correctly responded load 1
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 4 & ~ismember(data_mem.resp, [1, 3]) & data_mem.EEG_included == 1));
    accuracy(subi, 3) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 3) = median(data_mem.RT(tmp));
end   

%Prepare data for plotting
acc2plot = num2cell(accuracy', 2);
rt2plot = num2cell(rt', 2);
data2plot = {acc2plot, rt2plot};

%Initialize important variables for plotting
[cb] = cbrewer('div', 'RdBu', 12, 'pchip');
transparency = linspace(.5, .1, 3);

cl(1, :) = cb(2, :);

%Plot
for figi = 1 : 2
    
    figure;
    my_handle = rm_raincloud(data2plot{figi}, cl, 0, 'ks', [], 'median');

    %Prettify
    %Change color of individual plots
    my_handle.s{1}.SizeData = 50;
    my_handle.m(1).MarkerEdgeColor = 'none';
    my_handle.p{1}.FaceAlpha = transparency(1);
    my_handle.s{1}.MarkerFaceAlpha = transparency(1);
    my_handle.m(1).MarkerFaceAlpha = transparency(1);

    my_handle.m(2).MarkerEdgeColor = 'none';
    my_handle.p{2}.FaceAlpha = transparency(2);
    my_handle.s{2}.MarkerFaceAlpha = transparency(2);
    my_handle.m(2).MarkerFaceAlpha = transparency(2);

    my_handle.m(3).MarkerEdgeColor = 'none';
    my_handle.p{3}.FaceAlpha = transparency(3);
    my_handle.s{3}.MarkerFaceAlpha = transparency(3);
    my_handle.m(3).MarkerFaceAlpha = transparency(3);

    %Remove line connecting dots
    my_handle.l(1).Color = 'none';
    my_handle.l(2).Color = 'none';
    
    if figi == 1
        %Fix axes
        set(gca, 'XLim', [0, 1.2], 'XTick', [0, 0.5, 1.0, 1.2], 'XTickLabel', {'0', '50', '100', ' '}, ...
            'YTickLabel', {'Load 4', 'Load 2', 'Load 1'}); %axes have been flipped for the plots, so labels need to be reversed as well

        %Plot chance
        hold on;
        %plot([-100000 : 0.1 : 100000] .* 0.5, 'k--');
        line([0.5 0.5], [-5 30], 'color','k','linestyle',':');

        printfig(gcf, [0 0 20 8], [res_path 'Group_Accuracy_Load.tiff']);
    elseif figi == 2
        set(gca, 'XLim', [-1, 5], 'XTick', [0, 1, 2, 3, 4, 5], 'XTickLabel', {'0', '1', '2', '3', '4', '5'}, ...
            'YTickLabel', {'Load 4', 'Load 2', 'Load 1'}); %axes have been flipped for the plots, so labels need to be reversed as well
        printfig(gcf, [0 0 20 8], [res_path 'Group_RT_Load.tiff']);
    end
end

%% Load x Task rule effect (accuracy/RT)
clear ('acc2plot', 'accuracy', 'rt', 'rt2plot', 'data2plot'); 

for subi = 1 : length(subnips)
    
    load([res_path subnips{subi} '_' condition '_behavior.mat']);
    
    %Load = 1, rule = collect match, probe = match (possible responses: 1, 4)
    tmp = (data_mem.load == 1 & data_mem.cue == 0 & data_mem.probe == 0 & data_mem.resp == 1 & data_mem.EEG_included == 1); %correctly collected match
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 1 & data_mem.cue == 0 & data_mem.probe == 0 & data_mem.resp ~= 1 & data_mem.EEG_included == 1));
    accuracy(subi, 1) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 1) = median(data_mem.RT(tmp));
    
    %Load = 2, rule = collect match, probe = match (possible responses: 1, 4)
    tmp = (data_mem.load == 2 & data_mem.cue == 0 & data_mem.probe == 0 & data_mem.resp == 1 & data_mem.EEG_included == 1); %correctly collected match
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 2 & data_mem.cue == 0 & data_mem.probe == 0 & data_mem.resp ~= 1 & data_mem.EEG_included == 1));
    accuracy(subi, 2) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 2) = median(data_mem.RT(tmp));
    
    %Load = 4, rule = collect match, probe = match (possible responses: 1, 4)
    tmp = (data_mem.load == 4 & data_mem.cue == 0 & data_mem.probe == 0 & data_mem.resp == 1 & data_mem.EEG_included == 1); %correctly collected match
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 4 & data_mem.cue == 0 & data_mem.probe == 0 & data_mem.resp ~= 1 & data_mem.EEG_included == 1));
    accuracy(subi, 3) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 3) = median(data_mem.RT(tmp));
    
    %Load = 1, rule = collect match, probe = mismatch (possible responses: 2, 3)
    tmp = (data_mem.load == 1 & data_mem.cue == 0 & data_mem.probe == 1 & data_mem.resp == 3 & data_mem.EEG_included == 1); %correctly rejected mismatch
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 1 & data_mem.cue == 0 & data_mem.probe == 1 & data_mem.resp ~= 3 & data_mem.EEG_included == 1));
    accuracy(subi, 4) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 4) = median(data_mem.RT(tmp));
    
    %Load = 2, rule = collect match, probe = mismatch (possible responses: 2, 3)
    tmp = (data_mem.load == 2 & data_mem.cue == 0 & data_mem.probe == 1 & data_mem.resp == 3 & data_mem.EEG_included == 1); %correctly rejected mismatch
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 2 & data_mem.cue == 0 & data_mem.probe == 1 & data_mem.resp ~= 3 & data_mem.EEG_included == 1));
    accuracy(subi, 5) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 5) = median(data_mem.RT(tmp));
    
    %Load = 4, rule = collect match, probe = mismatch (possible responses: 2, 3)
    tmp = (data_mem.load == 4 & data_mem.cue == 0 & data_mem.probe == 1 & data_mem.resp == 3 & data_mem.EEG_included == 1); %correctly rejected mismatch
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 4 & data_mem.cue == 0 & data_mem.probe == 1 & data_mem.resp ~= 3 & data_mem.EEG_included == 1));
    accuracy(subi, 6) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 6) = median(data_mem.RT(tmp));
    
    %Load = 1, rule = collect mismatch, probe = mismatch (possible responses: 1, 4)
    tmp = (data_mem.load == 1 & data_mem.cue == 1 & data_mem.probe == 1 & data_mem.resp == 1 &  data_mem.EEG_included == 1); %correctly collected mismatch
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 1 & data_mem.cue == 1 & data_mem.probe == 1 & data_mem.resp ~= 1 & data_mem.EEG_included == 1));
    accuracy(subi, 7) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 7) = median(data_mem.RT(tmp));
    
    %Load = 2, rule = collect mismatch, probe = mismatch (possible responses: 1, 4)
    tmp = (data_mem.load == 2 & data_mem.cue == 1 & data_mem.probe == 1 & data_mem.resp == 1 &  data_mem.EEG_included == 1); %correctly collected mismatch
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 2 & data_mem.cue == 1 & data_mem.probe == 1 & data_mem.resp ~= 1 & data_mem.EEG_included == 1));
    accuracy(subi, 8) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 8) = median(data_mem.RT(tmp));
    
    %Load = 4, rule = collect mismatch, probe = mismatch (possible responses: 1, 4)
    tmp = (data_mem.load == 4 & data_mem.cue == 1 & data_mem.probe == 1 & data_mem.resp == 1 &  data_mem.EEG_included == 1); %correctly collected mismatch
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 4 & data_mem.cue == 1 & data_mem.probe == 1 & data_mem.resp ~= 1 & data_mem.EEG_included == 1));
    accuracy(subi, 9) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 9) = median(data_mem.RT(tmp));
    
    %Load = 1, rule = collect mismatch, probe = match (possible responses: 2, 3)
    tmp = (data_mem.load == 1 & data_mem.cue == 1 & data_mem.probe == 0 & data_mem.resp == 3 & data_mem.EEG_included == 1); %correctly rejected match
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 1 & data_mem.cue == 1 & data_mem.probe == 0 & data_mem.resp ~= 3 & data_mem.EEG_included == 1));
    accuracy(subi, 10) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 10)= median(data_mem.RT(tmp));
    
    %Load = 2, rule = collect mismatch, probe = match (possible responses: 2, 3)
    tmp = (data_mem.load == 2 & data_mem.cue == 1 & data_mem.probe == 0 & data_mem.resp == 3 & data_mem.EEG_included == 1); %correctly rejected match
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 2 & data_mem.cue == 1 & data_mem.probe == 0 & data_mem.resp ~= 3 & data_mem.EEG_included == 1));
    accuracy(subi, 11) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 11)= median(data_mem.RT(tmp));
    
    %Load = 4, rule = collect mismatch, probe = match (possible responses: 2, 3)
    tmp = (data_mem.load == 4 & data_mem.cue == 1 & data_mem.probe == 0 & data_mem.resp == 3 & data_mem.EEG_included == 1); %correctly rejected match
    tmp_correct = sum(tmp); 
    tmp_incorrect = sum((data_mem.load == 4 & data_mem.cue == 1 & data_mem.probe == 0 & data_mem.resp ~= 3 & data_mem.EEG_included == 1));
    accuracy(subi, 12) = tmp_correct / sum([tmp_correct, tmp_incorrect]);
    rt(subi, 12)= median(data_mem.RT(tmp));
end   

%Prepare data for plotting
acc2plot = num2cell(accuracy', 2);
rt2plot = num2cell(rt', 2);
data2plot = {acc2plot, rt2plot};

%Initialize important variables for plotting
[cb] = cbrewer('div', 'RdBu', 12, 'pchip');
transparency = linspace(.5, .1, 3);

cl(1, :) = cb(2, :);

%Plot
for figi = 1 : 2
    
    figure;
    [my_handle, my_YTicks] = rm_raincloud(data2plot{figi}, cl, 0, 'ks', [], 'median');

    %Prettify
    %Change color of individual plots
    for patchi = 1 : 3
        my_handle.s{patchi}.SizeData = 50;
        my_handle.m(patchi).MarkerEdgeColor = 'none';
        my_handle.p{patchi}.FaceAlpha = transparency(patchi);
        my_handle.s{patchi}.MarkerFaceAlpha = transparency(patchi);
        my_handle.m(patchi).MarkerFaceAlpha = transparency(patchi);
        %my_handle.p{patchi}.HandleVisibility = 'on';
        %my_handle.s{patchi}.HandleVisibility = 'off';
        %my_handle.m(patchi).HandleVisibility = 'off';
        %my_handle.p{patchi}.DisplayName = 'Load 1';
    end
    
    for patchi = 4 : 6
        my_handle.p{patchi}.FaceColor = cb(3, :);
        my_handle.s{patchi}.Marker = 'o';
        my_handle.s{patchi}.MarkerFaceColor = cb(3, :);
        my_handle.s{patchi}.SizeData = 50;
        my_handle.m(patchi).MarkerFaceColor = cb(3, :);
        my_handle.m(patchi).MarkerEdgeColor = 'none';
        my_handle.p{patchi}.FaceAlpha = transparency(patchi-3);
        my_handle.s{patchi}.MarkerFaceAlpha = transparency(patchi-3);
        my_handle.m(patchi).MarkerFaceAlpha = transparency(patchi-3);
        %my_handle.p{patchi}.HandleVisibility = 'off';
    end
    
    for patchi = 7 : 9
        my_handle.p{patchi}.FaceColor = cb(11, :);
        my_handle.s{patchi}.Marker = 'o';
        my_handle.s{patchi}.MarkerFaceColor = cb(11, :);
        my_handle.s{patchi}.SizeData = 50;
        my_handle.m(patchi).MarkerFaceColor = cb(11, :);
        my_handle.m(patchi).MarkerEdgeColor = 'none';
        my_handle.p{patchi}.FaceAlpha = transparency(patchi-6);
        my_handle.s{patchi}.MarkerFaceAlpha = transparency(patchi-6);
        my_handle.m(patchi).MarkerFaceAlpha = transparency(patchi-6);
        %my_handle.p{patchi}.HandleVisibility = 'off';
    end
    
   for patchi = 10 : 12
        my_handle.p{patchi}.FaceColor = cb(10, :);
        my_handle.s{patchi}.Marker = 'o';
        my_handle.s{patchi}.MarkerFaceColor = cb(10, :);
        my_handle.s{patchi}.SizeData = 50;
        my_handle.m(patchi).MarkerFaceColor = cb(10, :);
        my_handle.m(patchi).MarkerEdgeColor = 'none';
        my_handle.p{patchi}.FaceAlpha = transparency(patchi-9);
        my_handle.s{patchi}.MarkerFaceAlpha = transparency(patchi-9);
        my_handle.m(patchi).MarkerFaceAlpha = transparency(patchi-9);
        %my_handle.p{patchi}.HandleVisibility = 'off';
   end

    %Remove line connecting dots
    for linei = 1 : 11
        my_handle.l(linei).Color = 'none';
    end
    
    %Legend
%     leg = get(gca, 'Children');
%     [t1, t2] = legend([leg(47), leg(45), leg(43)], {'Load 1', 'Load 2', 'Load 4'}, 'Location', 'north');
%     PatchInLegend = findobj(t2, 'type', 'patch');
%     set(PatchInLegend(1), 'facea', transparency(1));
%     set(PatchInLegend(2), 'facea', transparency(2));
%     set(PatchInLegend(3), 'facea', transparency(3));
%     
    if figi == 1
        %Fix axes
        %set(gca, 'XLim', [0, 1.4], 'XTick', [0, 0.5, 1.0, 1.4], 'XTickLabel', {'0', '50', '100', ' '}, 'YTick', [my_YTicks(11 : -3: 0)], ...
            %'YTickLabel', {'Reject mismatch', 'Collect mismatch', 'Reject match', 'Collect match'}); %axes have been flipped for the plots, so labels need to be reversed as well
        
        set(gca, 'XLim', [0, 1.4], 'XTick', [0, 0.5, 1.0, 1.4], 'XTickLabel', {'0', '50', '100', ' '}, 'YTick', [my_YTicks(11 : -3: 0)], ...
            'YTickLabel', {'Reject match', 'Collect mismatch', 'Reject mismatch', 'Collect match'}); %axes have been flipped for the plots, so labels need to be reversed as well

        %Plot chance
        hold on;
        %plot([-100000 : 0.1 : 100000] .* 0.5, 'k--');
        line([0.5 0.5], [-20 120], 'color','k','linestyle',':');

        printfig(gcf, [0 0 26 8], [res_path 'Group_Accuracy_LoadxTaskRuleEffect.tiff']);
    elseif figi == 2
        %set(gca, 'XLim', [-1, 6], 'XTick', [0, 1, 2, 3, 4, 5, 6], 'XTickLabel', {'0', '1', '2', '3', '4', '5', '6'}, 'YTick', [my_YTicks(11 : -3: 0)], ...
            %'YTickLabel',  {'Reject mismatch', 'Collect mismatch', 'Reject match', 'Collect match'}); %axes have been flipped for the plots, so labels need to be reversed as well
        set(gca, 'XLim', [-1, 6], 'XTick', [0, 1, 2, 3, 4, 5, 6], 'XTickLabel', {'0', '1', '2', '3', '4', '5', '6'}, 'YTick', [my_YTicks(11 : -3: 0)], ...
            'YTickLabel',  {'Reject match', 'Collect mismatch', 'Reject mismatch', 'Collect match'}); %axes have been flipped for the plots, so labels need to be reversed as well
        printfig(gcf, [0 0 26 8], [res_path 'Group_RT_LoadxTaskRuleEffect.tiff']);
    end
end


    