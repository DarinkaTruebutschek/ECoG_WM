%This script computes the frequency with which different memory stim were
%presented in different locations.
%Project: ECoG_WM
%Author: D.T.
%Date: 05 October 2020

clear all;
clc;
close all;

%% Path
ECoG_setPath;

%% Define important variables
subnips = {'EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP'};
condition = 'memory';

%% Load both existing behavioral tables and combine into a single one
for subi = 1 : length(subnips)
    iEEG = load([behavior_path subnips{subi} '_memory_behavior.mat']);
    locs = load([behavior_path subnips{subi} '_memory_behavior_withLocs.mat']);
    
    %Add missing trialinfo for subject MKL
    if strcmp(subnips{subi}, 'MKL')
        tmp = [iEEG.data_mem(1:80, 1:16)];
        tmp.stimA_angle = zeros(80, 1);
        tmp.stimB_angle = zeros(80, 1);
        tmp.stimC_angle = zeros(80, 1);
        tmp.stimD_angle = zeros(80, 1);
        
        tmp = [tmp; locs.data_mem];
        locs.data_mem = tmp;
        
        clear('tmp');
    end
    
    %Combine existing tables to have both info on stim locations & info on
    %which trials have been included in the EEG analyses
    data_mem = iEEG.data_mem;
    data_mem.stimA_angle = locs.data_mem.stimA_angle;
    data_mem.stimB_angle = locs.data_mem.stimB_angle;
    data_mem.stimC_angle = locs.data_mem.stimC_angle;
    data_mem.stimD_angle = locs.data_mem.stimD_angle;
    
    %Replace non-existing loc info with nan
    data_mem.stimA_angle(data_mem.stimA_angle == 0) = NaN;
    data_mem.stimB_angle(data_mem.stimB_angle == 0) = NaN;
    data_mem.stimC_angle(data_mem.stimC_angle == 0) = NaN;
    data_mem.stimD_angle(data_mem.stimD_angle == 0) = NaN;
    
    %Save
    save([behavior_path subnips{subi} '_memory_behavior_combined.mat'], 'data_mem');
    
    %Clear
    clear('data_mem', 'iEEG', 'locs');
end

%% Establish how often a given memory stimulus has been presented in a given location
for subi = 1 : length(subnips)
    load([behavior_path subnips{subi} '_memory_behavior_combined.mat']);
    
    count_angle45 = data_mem.stimA_id(data_mem.EEG_included == 1 & data_mem.stimA_angle == 45);
    count_angle45 = [count_angle45; data_mem.stimB_id(data_mem.EEG_included == 1 & data_mem.stimB_angle == 45)];
    count_angle45 = [count_angle45; data_mem.stimC_id(data_mem.EEG_included == 1 & data_mem.stimC_angle == 45)];
    count_angle45 = [count_angle45; data_mem.stimD_id(data_mem.EEG_included == 1 & data_mem.stimD_angle == 45)];
    
    count_angle75 = data_mem.stimA_id(data_mem.EEG_included == 1 & data_mem.stimA_angle == 75);
    count_angle75 = [count_angle75; data_mem.stimB_id(data_mem.EEG_included == 1 & data_mem.stimB_angle == 75)];
    count_angle75 = [count_angle75; data_mem.stimC_id(data_mem.EEG_included == 1 & data_mem.stimC_angle == 75)];
    count_angle75 = [count_angle75; data_mem.stimD_id(data_mem.EEG_included == 1 & data_mem.stimD_angle == 75)];
    
    count_angle105 = data_mem.stimA_id(data_mem.EEG_included == 1 & data_mem.stimA_angle == 105);
    count_angle105 = [count_angle105; data_mem.stimB_id(data_mem.EEG_included == 1 & data_mem.stimB_angle == 105)];
    count_angle105 = [count_angle105; data_mem.stimC_id(data_mem.EEG_included == 1 & data_mem.stimC_angle == 105)];
    count_angle105 = [count_angle105; data_mem.stimD_id(data_mem.EEG_included == 1 & data_mem.stimD_angle == 105)];
    
    count_angle135 = data_mem.stimA_id(data_mem.EEG_included == 1 & data_mem.stimA_angle == 135);
    count_angle135 = [count_angle135; data_mem.stimB_id(data_mem.EEG_included == 1 & data_mem.stimB_angle == 135)];
    count_angle135 = [count_angle135; data_mem.stimC_id(data_mem.EEG_included == 1 & data_mem.stimC_angle == 135)];
    count_angle135 = [count_angle135; data_mem.stimD_id(data_mem.EEG_included == 1 & data_mem.stimD_angle == 135)];
    
    %Get info on overall position bias (i.e., how often was a given
    %location viewed)
    pos_bias{subi} = [length(count_angle45), length(count_angle75), length(count_angle105), length(count_angle135)];
    
    %Obtain frequency with which individual memory items were shown in a
    %given location
    for stimi = 1 : 10
        pos45_bias{subi}(stimi) = sum(count_angle45 == stimi-1);
        pos75_bias{subi}(stimi) = sum(count_angle75 == stimi-1);
        pos105_bias{subi}(stimi) = sum(count_angle105 == stimi-1);
        pos135_bias{subi}(stimi) = sum(count_angle135 == stimi-1);
    end
end

%% Compute relevant statistics
%First, check whether there exists any differences in the frequency
%with which items were shown in the 4 locations
for subi = 1 : length(subnips)
    [chi_square_value(subi), p_value(subi)] = chi_square(pos_bias{subi}, repmat(sum(pos_bias{subi})./4, 1, 4), 3);
end

%Next, check whether there exist any differences in  the frequencies with
%which individual items were shown in each of the four locations
for subi = 1 : length(subnips)
    [chi_square_value_45(subi), p_value_45(subi)] = chi_square(pos45_bias{subi}, repmat(sum(pos45_bias{subi})./10, 1, 10), 9);
    [chi_square_value_75(subi), p_value_75(subi)] = chi_square(pos75_bias{subi}, repmat(sum(pos75_bias{subi})./10, 1, 10), 9);
    [chi_square_value_105(subi), p_value_105(subi)] = chi_square(pos105_bias{subi}, repmat(sum(pos105_bias{subi})./10, 1, 10), 9);
    [chi_square_value_135(subi), p_value_135(subi)] = chi_square(pos135_bias{subi}, repmat(sum(pos135_bias{subi})./10, 1, 10), 9);
end

%Third, check whether, within-each subject, each item was shown equally
%often in each position
for subi= 1 : length(subnips)
    for itemi = 1 : 10
    [chi_square_value_item(subi, itemi), p_value_item(subi, itemi)] = chi_square([pos45_bias{subi}(itemi), pos75_bias{subi}(itemi), ...
        pos105_bias{subi}(itemi), pos135_bias{subi}(itemi)], repmat(sum([pos45_bias{subi}(itemi), pos75_bias{subi}(itemi), ...
        pos105_bias{subi}(itemi), pos135_bias{subi}(itemi)])./4, 1, 4), 3);
    end
end

%% Plot data for each subject as a pie chart
fig_titles = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', 'S11'};
subplot_titles = {'45 Deg.', '75 Deg.', '105 Deg.', '135 Deg.'};
subplot_pos = {[.1, .6, .3, .3], [.6, .6, .3, .3], [.1, .15, .3, .3], [.6, .15, .3, .3]};
legend_entries = {'Item1', 'Item2', 'Item3', 'Item4', 'Item5', 'Item6', 'Item7', 'Item8', 'Item9', 'Item10'};
my_colors = cbrewer('div', 'Spectral', 10);

for subi = 1 : length(subnips)
    freq45{subi} = pos45_bias{subi} ./ sum(pos45_bias{subi});
    freq75{subi} = pos75_bias{subi} ./ sum(pos75_bias{subi});
    freq105{subi} = pos105_bias{subi} ./ sum(pos105_bias{subi});
    freq135{subi} = pos135_bias{subi} ./ sum(pos135_bias{subi});
    
    tmp=[freq45{subi}; freq75{subi}; freq105{subi}; freq135{subi}];
    
    %Plot
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
    font_small = 12;
    font_medium = 14;
    font_large = 16;
    
    figure;
    for subploti = 1 : 4
        %subplot(2, 2, subploti);
        subplot('Position', subplot_pos{subploti});
        
        pie(tmp(subploti, :));
        set(gca, 'FontName', 'Arial', 'FontSize', font_small);
        colormap(my_colors);
        title(subplot_titles{subploti}, 'FontName', 'Arial', 'FontSize', font_medium, 'FontWeight', 'normal');
        
        %Move position of title title-
        titleHandle = get(gca, 'Title');
        title_pos = get(titleHandle, 'position');
        title_posNew = title_pos + [0 .05 0];
        set(titleHandle, 'position', title_posNew);
        
        legend(legend_entries{:}, 'Location', 'best', 'NumColumns', 6, 'FontName', 'Arial', 'FontSize', font_small);
        legend('boxon');
    end
    
    sgtitle(fig_titles{subi}, 'FontName', 'Arial', 'FontSize', font_large, 'FontWeight', 'Bold');
    
    printfig(gcf, [0 0 11 11], [behavior_path '/Figures/' subnips{subi} '_FreqPositions.tiff']);
    %close(gcf);
end