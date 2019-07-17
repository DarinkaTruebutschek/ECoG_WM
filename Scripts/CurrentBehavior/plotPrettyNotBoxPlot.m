%This function plots a pretty notBoxPlot. It takes as input a column
%matrix, where each column will be displayed as an individual box plot.
%Project: ECoG_WM
%Author: D.T.
%Date: 25 March 2019

function  plotPrettyNotBoxPlot(data, my_style, my_color, my_faceAlpha, my_xLim, my_yLim, my_axes, my_labels)

%% Default figure parameters
set(groot, 'DefaultFigureColor', 'w', ...
    'DefaultAxesLineWidth', 0.5, ...
    'DefaultAxesXColor', [.5, .5, .5], ...
    'DefaultAxesYColor', [.5, .5, .5], ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [.02, .025]);

set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');

%% Current figure
%Determine x ticks
x = [1 : size(data, 2)]; %corresponds to the number of bars plotted

%Diminish x-axis spacing
ticks = x - 0.5;

figure;
hold on

for ploti = 1 : x(end)
    display(num2str(ploti));
    my_box = notBoxPlot(data(:, ploti), ticks(ploti), 'style', my_style);

    %Plot mean as white line
    set([my_box.mu], 'Color', 'w', 'LineWidth', 1.5);

    %Change color of individual patches and sd lines
    set([my_box.semPtch], 'FaceColor', my_color(ploti, :), 'EdgeColor', my_color(ploti, :), 'FaceAlpha', my_faceAlpha);
    set([my_box.sd], 'Color', my_color(ploti, :), 'LineWidth', 1.5);
end

hold off

%Set x and ylim
if ~isempty(my_xLim)
    xlim(my_xLim);
    ylim(my_yLim);
else
    my_xLim = [0, max(x)+0.5];
    my_yLim = [0, max(max(data))+max(std(data))];
    xlim(my_xLim);
    ylim(my_yLim);
end

%Name x and y axis
xlabel(my_axes{1});
ylabel(my_axes{2});

set(gca, 'XTick', sort([my_xLim, ticks]), 'XTickLabels', my_labels, 'YTick', my_yLim, 'YTickLabels', {num2str(my_yLim(1)), num2str(round(my_yLim(2)))});
end