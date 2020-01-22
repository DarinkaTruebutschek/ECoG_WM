%This function specifies certain lighting conditions, in particular
%returning a given viewing position.
%Project: ECoG_WM
%Author: D.T.
%Date: 21 January 2020

function view_position = ECoG_defineLight(theta, phi)

view_position = [cosd(theta-90)*cosd(phi), sind(theta-90)*cosd(phi), sind(phi)];

end