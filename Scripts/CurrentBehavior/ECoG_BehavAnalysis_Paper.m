%This is the main script to run the behavioral analyses included in the
%paper.
%Project: ECoG_WM
%Author: D.T.
%Date: 18 September 2020

clear all; 
close all;
clc;

%% Set path
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};
condition = 'memory';

group_data = table();
%% Load data into one big table
for subi = 1 : length(subnips)
    
    %Load data
    load([behavior_path subnips{subi} '_' condition '_behavior.mat']);
    
    %Add column to represent subjects
    data_mem.subj = ones(length(data_mem.session_id), 1)*subi;
    
    %Append
    group_data = [group_data; data_mem];
    clear('data_mem');
end


%% Overall accuracy
acc = [];
chi_square_value = [];
p_value = [];

for subi = 1 : length(subnips)
    corr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 1 | group_data.resp == 3));
    incorr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 2 | group_data.resp == 4));
    
    acc(subi) = corr/(corr+incorr);
    
    %Chi-square test to assess whether subject performed better than chance
    [chi_square_value(subi), p_value(subi)] = chi_square([corr, incorr], [(corr+incorr)/2, (corr+incorr)/2]);
end

mean_acc = mean(acc);
std_acc = std(acc);
se_acc = std(acc)/sqrt(length(subnips));

%% RM-ANOVA (Task x probe x load): ACC
acc = [];
acc_task = [];
acc_load = [];
acc_int = [];

task = [0, 1]; %match vs mismatch
probe = [0, 1]; %match vs mismatch
load = [1, 2, 4];

for subi = 1 : length(subnips)
    for taski = 1 : length(task)
        for probei = 1 : length(probe)
            for loadi = 1 : length(load)
                
                display(['Task: ' num2str(taski) ', Probe: ' num2str(probei) ', Load: ' num2str(loadi)]);
                
                cue = task(taski);
                prob = probe(probei);
                wml = load(loadi);
                
                corr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 1 | group_data.resp == 3) & group_data.cue == cue & group_data.probe == prob & group_data.load == wml);
                incorr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 2 | group_data.resp == 4) & group_data.cue == cue & group_data.probe == prob & group_data.load == wml);
                
                acc(subi, taski, probei, loadi) = corr/(corr+incorr);
            end
        end
    end
end

%Main effect of task
for subi = 1 : length(subnips)
    for taski = 1 : length(task)
        cue = task(taski);
        corr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 1 | group_data.resp == 3) & group_data.cue == cue);
        incorr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 2 | group_data.resp == 4) & group_data.cue == cue);
        acc_task(subi, taski) = corr/(corr+incorr);
    end
end

mean_acc_task = mean(acc_task);
std_acc_task = std(acc_task);
se_acc_task = std(acc_task)/sqrt(length(subnips));

%Main effect of load
for subi = 1 : length(subnips)
    for loadi = 1 : length(load)
        wml = load(loadi);
        corr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 1 | group_data.resp == 3) & group_data.load == wml);
        incorr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 2 | group_data.resp == 4) & group_data.load == wml);
        acc_load(subi, loadi) = corr/(corr+incorr);
    end
end

mean_acc_load = mean(acc_load);
std_acc_load = std(acc_load);
se_acc_load = std(acc_load)/sqrt(length(subnips));
        
[~, p_value_l1vsl2, ~, stats_l1vsl2] = ttest(acc_load(:, 1), acc_load(:, 2), 'tail', 'both');
[~, p_value_l1vsl4, ~, stats_l1vsl4] = ttest(acc_load(:, 1), acc_load(:, 3), 'tail', 'both');
[~, p_value_l2vsl4, ~, stats_l2vsl4] = ttest(acc_load(:, 2), acc_load(:, 3), 'tail', 'both');

p_value = [p_value_l1vsl2, p_value_l1vsl4, p_value_l2vsl4];
t_value = [stats_l1vsl2.tstat, stats_l1vsl4.tstat, stats_l2vsl4.tstat];

%Task x probe interaction
for subi = 1 : length(subnips)
    for taski = 1 : length(task)
        for probei = 1 : length(probe)
            cue = task(taski);
            prob = probe(probei);
            corr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 1 | group_data.resp == 3) & group_data.cue == cue & group_data.probe == prob);
            incorr = sum(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 2 | group_data.resp == 4) & group_data.cue == cue & group_data.probe == prob);
            acc_int(subi, taski, probei) = corr/(corr+incorr);
        end
    end
end

mean_acc_int = mean(acc_int);
std_acc_int = std(acc_int);
se_acc_int = std(acc_int)/sqrt(length(subnips));

[~, p_value_MaMa_MaMi, ~, stats_MaMa_MaMi] = ttest(acc_int(:, 1, 1), acc_int(:, 1, 2), 'tail', 'both');
[~, p_value_MaMa_MiMa, ~, stats_MaMa_MiMa] = ttest(acc_int(:, 1, 1), acc_int(:, 2, 1), 'tail', 'both');
[~, p_value_MaMa_MiMi, ~, stats_MaMa_MiMi] = ttest(acc_int(:, 1, 1), acc_int(:, 2, 2), 'tail', 'both');
[~, p_value_MaMi_MiMa, ~, stats_MaMi_MiMa] = ttest(acc_int(:, 1, 2), acc_int(:, 2, 1), 'tail', 'both');
[~, p_value_MaMi_MiMi, ~, stats_MaMi_MiMi] = ttest(acc_int(:, 1, 2), acc_int(:, 2, 2), 'tail', 'both');
[~, p_value_MiMa_MiMi, ~, stats_MiMa_MiMi] = ttest(acc_int(:, 2, 1), acc_int(:, 2, 2), 'tail', 'both');

p_value = [p_value_MaMa_MaMi, p_value_MaMa_MiMa, p_value_MaMa_MiMi, p_value_MaMi_MiMa, p_value_MaMi_MiMi, p_value_MiMa_MiMi];
t_value = [stats_MaMa_MaMi.tstat, stats_MaMa_MiMa.tstat, stats_MaMa_MiMi.tstat, stats_MaMi_MiMa.tstat, stats_MaMi_MiMi.tstat, stats_MiMa_MiMi.tstat];

%% RM-ANOVA (Task x probe x load): RT
rt = [];
rt_task = [];
rt_load = [];
rt_int = [];

task = [0, 1]; %match vs mismatch
probe = [0, 1]; %match vs mismatch
load = [1, 2, 4];

for subi = 1 : length(subnips)
    for taski = 1 : length(task)
        for probei = 1 : length(probe)
            for loadi = 1 : length(load)
                
                display(['Task: ' num2str(taski) ', Probe: ' num2str(probei) ', Load: ' num2str(loadi)]);
                
                cue = task(taski);
                prob = probe(probei);
                wml = load(loadi);
                
                rt(subi, taski, probei, loadi) = mean(group_data.RT(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 1 | group_data.resp == 3) & group_data.cue == cue & group_data.probe == prob & group_data.load == wml));
            end
        end
    end
end

%Main effect of task
for subi = 1 : length(subnips)
    for taski = 1 : length(task)
        cue = task(taski);
        rt_task(subi, taski) = mean(group_data.RT(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 1 | group_data.resp == 3) & group_data.cue == cue));
    end
end

mean_rt_task = mean(rt_task);
std_rt_task = std(rt_task);
se_rt_task = std(rt_task)/sqrt(length(subnips));

%Main effect of load
for subi = 1 : length(subnips)
    for loadi = 1 : length(load)
        wml = load(loadi);
        rt_load(subi, loadi) = mean(group_data.RT(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 1 | group_data.resp == 3) & group_data.load == wml));
    end
end

mean_rt_load = mean(rt_load);
std_rt_load = std(rt_load);
se_rt_load = std(rt_load)/sqrt(length(subnips));
        
[~, p_value_l1vsl2, ~, stats_l1vsl2] = ttest(rt_load(:, 1), rt_load(:, 2), 'tail', 'both');
[~, p_value_l1vsl4, ~, stats_l1vsl4] = ttest(rt_load(:, 1), rt_load(:, 3), 'tail', 'both');
[~, p_value_l2vsl4, ~, stats_l2vsl4] = ttest(rt_load(:, 2), rt_load(:, 3), 'tail', 'both');

p_value = [p_value_l1vsl2, p_value_l1vsl4, p_value_l2vsl4];
t_value = [stats_l1vsl2.tstat, stats_l1vsl4.tstat, stats_l2vsl4.tstat];

%Task x probe interaction
for subi = 1 : length(subnips)
    for taski = 1 : length(task)
        for probei = 1 : length(probe)
            cue = task(taski);
            prob = probe(probei);
            rt_int(subi, taski, probei) = mean(group_data.RT(group_data.subj == subi & group_data.EEG_included == 1 & (group_data.resp == 1 | group_data.resp == 3) & group_data.cue == cue & group_data.probe == prob));
        end
    end
end

mean_rt_int = mean(rt_int);
std_rt_int = std(rt_int);
se_rt_int = std(rt_int)/sqrt(length(subnips));

[~, p_value_MaMa_MaMi, ~, stats_MaMa_MaMi] = ttest(rt_int(:, 1, 1), rt_int(:, 1, 2), 'tail', 'both');
[~, p_value_MaMa_MiMa, ~, stats_MaMa_MiMa] = ttest(rt_int(:, 1, 1), rt_int(:, 2, 1), 'tail', 'both');
[~, p_value_MaMa_MiMi, ~, stats_MaMa_MiMi] = ttest(rt_int(:, 1, 1), rt_int(:, 2, 2), 'tail', 'both');
[~, p_value_MaMi_MiMa, ~, stats_MaMi_MiMa] = ttest(rt_int(:, 1, 2), rt_int(:, 2, 1), 'tail', 'both');
[~, p_value_MaMi_MiMi, ~, stats_MaMi_MiMi] = ttest(rt_int(:, 1, 2), rt_int(:, 2, 2), 'tail', 'both');
[~, p_value_MiMa_MiMi, ~, stats_MiMa_MiMi] = ttest(rt_int(:, 2, 1), rt_int(:, 2, 2), 'tail', 'both');

p_value = [p_value_MaMa_MaMi, p_value_MaMa_MiMa, p_value_MaMa_MiMi, p_value_MaMi_MiMa, p_value_MaMi_MiMi, p_value_MiMa_MiMi];
t_value = [stats_MaMa_MaMi.tstat, stats_MaMa_MiMa.tstat, stats_MaMa_MiMi.tstat, stats_MaMi_MiMa.tstat, stats_MaMi_MiMi.tstat, stats_MiMa_MiMi.tstat];

%% Plot ACC (2 subplots for the different task rules: probe * load)
%Reshape data to facilitate plotting
acc_reshaped = [];

acc_reshaped(1, :, 1) = acc(:, 1, 1, 1);
acc_reshaped(1, :, 2) = acc(:, 1, 1, 2);
acc_reshaped(1, :, 3) = acc(:, 1, 1, 3);
acc_reshaped(1, :, 4) = acc(:, 1, 2, 1);
acc_reshaped(1, :, 5) = acc(:, 1, 2, 2);
acc_reshaped(1, :, 6) = acc(:, 1, 2, 3);

acc_reshaped(2, :, 1) = acc(:, 2, 1, 1);
acc_reshaped(2, :, 2) = acc(:, 2, 1, 2);
acc_reshaped(2, :, 3) = acc(:, 2, 1, 3);
acc_reshaped(2, :, 4) = acc(:, 2, 2, 1);
acc_reshaped(2, :, 5) = acc(:, 2, 2, 2);
acc_reshaped(2, :, 6) = acc(:, 2, 2, 3);

%Default figure parameters
set(groot, 'DefaultFigureColor', 'w', ...
    'DefaultAxesLineWidth', 0.5, ...
    'DefaultAxesXColor', [.5, .5, .5], ...
    'DefaultAxesYColor', [.5, .5, .5], ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [.02, .025]);

set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');

%Fig Params
FaceAlpha = [1, .75, .5, 1, .75, .5];
font_small = 12;
font_medium = 14;
font_large = 16;

%Plot
for taski = 1 : 2
    
    %Set up colors
    if taski == 1
        C = [178, 24, 43; 178, 24, 43; 178, 24, 43; ...
            239, 138, 98; 239, 138, 98; 239, 138, 98] ./255;
        
        LineAlpha = [178/255, 24/255, 43/255, 1; 178/255, 24/255, 43/255, .75; 178/255, 24/255, 43/255, .5; ...
            239/255, 138/255, 98/255, 1; 239/255, 138/255, 98/255, .75; 239/255, 138/255, 98/255, .5];
    else
        C = [33, 102, 172; 33, 102, 172; 33, 102, 172; ...
            103, 169, 207; 103, 169, 207; 103, 169, 207] ./ 255;
        
         LineAlpha = [33/255, 102/255, 172/255, 1; 33/255, 102/255, 172/255, .75; 33/255, 102/255, 172/255, .5; ...
            103/255, 169/255, 207/255, 1; 103/255, 169/255, 207/255, .75; 103/255, 169/255, 207/255, .5];
    end
    
    y = squeeze(acc_reshaped(taski, :, :));
    %x = [1:6]';
    x = [1, 1.5, 2, 3, 3.5, 4];
    
    figure;
    [H, stats] = notBoxPlot(y, x, 'style', 'sdline');
    
    %Plot mean as white line
    set([H.mu], 'Color', 'w', 'LineWidth', 1.5);
    
    %Change color of individual patches, sd lines, and circles
    for bari = 1 : 6
        set([H(:, bari).semPtch], 'FaceColor', C(bari, :), 'EdgeColor', [1, 1, 1], 'FaceAlpha', FaceAlpha(bari));
        set([H(:, bari).sd], 'Color', LineAlpha(bari, :), 'LineWidth', 1.5);
        set([H(:, bari).data], 'Color', [0, 0, 0], 'MarkerSize', 5);
    end
    
    %Legend
    Hleg = legend([H(:, 1).semPtch, H(:, 2).semPtch, H(:, 3).semPtch], 'Load1', 'Load2', 'Load4', 'Location', 'southwest', 'Fontname', 'Arial', 'FontSize', font_small);
    
    %Figure props
    ylim([0, 1]);
    xlim([0.5, 4.5]);
    
    set(gca, 'xtick', [1.5, 3.5], 'xticklabel', {'Probe-Match', 'Probe-Mismatch'}, 'FontName', 'Arial', 'FontSize', font_medium);
    set(gca, 'ytick', [0, .25, .5, .75, 1], 'yticklabel', {'0', '25', '50', '75', '100'}, 'FontName', 'Arial', 'FontSize', font_medium);
    
    ylabel('% trials', 'FontName', 'Arial', 'FontSize', font_large);
    %xlabel('Probe', 'FontName', 'Arial', 'FontSize', 14);
    
    if taski == 1
        title('Task: Collect match', 'FontName', 'Arial', 'FontSize', font_large, 'FontWeight', 'Bold');
        printfig(gcf, [0 0 10 10], [behavior_path '/Figures/Group_Acc_behav_Task1.tiff']);
    else
        title('Task: Collect mismatch', 'FontName', 'Arial', 'FontSize', font_large, 'FontWeight', 'Bold');
        printfig(gcf, [0 0 10 10], [behavior_path '/Figures/Group_Acc_behav_Task2.tiff']);
    end
end

%% Plot RT (2 subplots for the different task rules: probe * load)
%Reshape data to facilitate plotting
rt_reshaped = [];

rt_reshaped(1, :, 1) = rt(:, 1, 1, 1);
rt_reshaped(1, :, 2) = rt(:, 1, 1, 2);
rt_reshaped(1, :, 3) = rt(:, 1, 1, 3);
rt_reshaped(1, :, 4) = rt(:, 1, 2, 1);
rt_reshaped(1, :, 5) = rt(:, 1, 2, 2);
rt_reshaped(1, :, 6) = rt(:, 1, 2, 3);

rt_reshaped(2, :, 1) = rt(:, 2, 1, 1);
rt_reshaped(2, :, 2) = rt(:, 2, 1, 2);
rt_reshaped(2, :, 3) = rt(:, 2, 1, 3);
rt_reshaped(2, :, 4) = rt(:, 2, 2, 1);
rt_reshaped(2, :, 5) = rt(:, 2, 2, 2);
rt_reshaped(2, :, 6) = rt(:, 2, 2, 3);

%Default figure parameters
set(groot, 'DefaultFigureColor', 'w', ...
    'DefaultAxesLineWidth', 0.5, ...
    'DefaultAxesXColor', [.5, .5, .5], ...
    'DefaultAxesYColor', [.5, .5, .5], ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [.02, .025]);

set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');

%Fig Params
FaceAlpha = [1, .75, .5, 1, .75, .5];
font_small = 12;
font_medium = 14;
font_large = 16;

%Plot
for taski = 1 : 2
    
    %Set up colors
    if taski == 1
        C = [178, 24, 43; 178, 24, 43; 178, 24, 43; ...
            239, 138, 98; 239, 138, 98; 239, 138, 98] ./255;
        
        LineAlpha = [178/255, 24/255, 43/255, 1; 178/255, 24/255, 43/255, .75; 178/255, 24/255, 43/255, .5; ...
            239/255, 138/255, 98/255, 1; 239/255, 138/255, 98/255, .75; 239/255, 138/255, 98/255, .5];
    else
        C = [33, 102, 172; 33, 102, 172; 33, 102, 172; ...
            103, 169, 207; 103, 169, 207; 103, 169, 207] ./ 255;
        
         LineAlpha = [33/255, 102/255, 172/255, 1; 33/255, 102/255, 172/255, .75; 33/255, 102/255, 172/255, .5; ...
            103/255, 169/255, 207/255, 1; 103/255, 169/255, 207/255, .75; 103/255, 169/255, 207/255, .5];
    end
    
    y = squeeze(rt_reshaped(taski, :, :));
    %x = [1:6]';
    x = [1, 1.5, 2, 3, 3.5, 4];
    
    figure;
    [H, stats] = notBoxPlot(y, x, 'style', 'sdline');
    
    %Plot mean as white line
    set([H.mu], 'Color', 'w', 'LineWidth', 1.5);
    
    %Change color of individual patches, sd lines, and circles
    for bari = 1 : 6
        set([H(:, bari).semPtch], 'FaceColor', C(bari, :), 'EdgeColor', [1, 1, 1], 'FaceAlpha', FaceAlpha(bari));
        set([H(:, bari).sd], 'Color', LineAlpha(bari, :), 'LineWidth', 1.5);
        set([H(:, bari).data], 'Color', [0, 0, 0], 'MarkerSize', 5);
    end
    
    %Legend
    Hleg = legend([H(:, 1).semPtch, H(:, 2).semPtch, H(:, 3).semPtch], 'Load1', 'Load2', 'Load4', 'Location', 'northeast', 'Fontname', 'Arial', 'FontSize', font_small);
    
    %Figure props
    ylim([0, 6]);
    xlim([0.5, 4.5]);
    
    set(gca, 'xtick', [1.5, 3.5], 'xticklabel', {'Probe-Match', 'Probe-Mismatch'}, 'FontName', 'Arial', 'FontSize', font_medium);
    set(gca, 'ytick', [0, 2, 4, 6], 'yticklabel', {'0', '2', '4', '6'}, 'FontName', 'Arial', 'FontSize', font_medium);
    
    ylabel('Reaction time', 'FontName', 'Arial', 'FontSize', font_large);
    %xlabel('Probe', 'FontName', 'Arial', 'FontSize', 14);
    
    if taski == 1
        title('Task: Collect match', 'FontName', 'Arial', 'FontSize', font_large, 'FontWeight', 'Bold');
        printfig(gcf, [0 0 10 10], [behavior_path '/Figures/Group_RT_behav_Task1.tiff']);
    else
        title('Task: Collect mismatch', 'FontName', 'Arial', 'FontSize', font_large, 'FontWeight', 'Bold');
        printfig(gcf, [0 0 10 10], [behavior_path '/Figures/Group_RT_behav_Task2.tiff']);
    end
end

 