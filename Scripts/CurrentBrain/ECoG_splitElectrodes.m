%This function splits the electrode file according to anatomical landmarks,
%e.g. hemisphere
%Project: ECoG_WM
%Author: D.T.
%Date: 23 May 2019

function [electrodes, ind] = ECoG_splitElectrodes(dataIn, chansel)

electrodes = dataIn;

%First, find the indices of the channels to be included
chansel = ft_channelselection(chansel, dataIn.label); %get actual channel names to be included
ind = ismember(electrodes.label, chansel);

%Then, update all of these fields in the electrodes struc
electrodes.chanpos = electrodes.chanpos(ind, :);
electrodes.chantype = electrodes.chantype(ind);
electrodes.chanunit = electrodes.chanunit(ind);
electrodes.elecpos = electrodes.chanpos;
electrodes.label = electrodes.label(ind);
electrodes.tra = eye(sum(ind));
end