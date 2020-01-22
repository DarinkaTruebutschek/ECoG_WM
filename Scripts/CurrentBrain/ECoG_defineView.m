%This function specifies certain viewpoints.
%Project: ECoG_WM
%Author: D.T.
%Date: 21 January 2020

function [theta, phi] = ECoG_defineView(hemisphere, viewside)

if strcmp(hemisphere, 'left')
    switch viewside
        case 'lateral'
            theta = 270;
            phi = 0;
        case 'medial'
            theta = 90;
            phi = 0;
    end
elseif strcmp(hemisphere, 'right')
    switch viewside
        case 'medial'
            theta = 270;
            phi = 0;
        case 'lateral'
            theta = 90;
            phi = 0;
    end
end
end