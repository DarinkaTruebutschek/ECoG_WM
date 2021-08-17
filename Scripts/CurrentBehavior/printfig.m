%This function prints a figure according to given dimensions.
%Project: ECoG_WM
%Author: D.T.
%Date: 22 March 2019

function printfig(h, papersize, filename)

set(h, 'PaperUnits', 'centimeters', 'PaperPosition', papersize)
ppos = get(h, 'PaperPosition');
su = get(h, 'Units');
pu = get(h, 'PaperUnits');
set(h, 'Units', pu);
spos = get(h, 'Position');
set(h,'Position',[spos(1) spos(2) ppos(3) ppos(4)])
set(h,'Units',su)

if ~isempty(filename)
    print(h, '-r600', '-dpdf', filename);
    %print(h, '-r600', '-dtiff', filename);
end

end