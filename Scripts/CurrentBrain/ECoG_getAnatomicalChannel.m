%This functions assigns an anatomical label for a given channel position
%Project: ECoG_WM
%Author: D.T.
%Date: 28 September 2020

function anatomicalLabel = ECoG_getAnatomicalChannel(label, subject, atlas)

%Load data
anatLabels = readtable(['/media/darinka/Data0/iEEG/Results/Electrodes/' subject '/' subject '_elec_pos_final.xlsx']);

%Extract anatomical labels
for labeli = 1 : length(label)
    
    if strcmp(atlas, 'AFNI')
        anatomicalLabel{labeli} = anatLabels.AFNI(find(strcmp(anatLabels.Electrode, label{labeli})));
    elseif strcmp(atlas, 'AAL')
        anatomicalLabel{labeli} = anatLabels.AAL(find(strcmp(anatLabels.Electrode, label{labeli})));
    elseif strcmp(atlas, 'BrainWeb')
        anatomicalLabel{labeli} = anatLabels.BrainWeb(find(strcmp(anatLabels.Electrode, label{labeli})));
    elseif strcmp(atlas, 'JuBrain')
        anatomicalLabel{labeli} = anatLabels.JuBrain(find(strcmp(anatLabels.Electrode, label{labeli})));
    elseif strcmp(atlas, 'VTPM')
        anatomicalLabel{labeli} = anatLabels.VTPM(find(strcmp(anatLabels.Electrode, label{labeli})));
    elseif strcmp(atlas, 'Brainnetome')
        anatomicalLabel{labeli} = anatLabels.Brainnetome(find(strcmp(anatLabels.Electrode, label{labeli})));
    elseif strcmp(atlas, 'Desikan_Killiany')
        anatomicalLabel{labeli} = anatLabels.Desikan_Killiany(find(strcmp(anatLabels.Electrode, label{labeli})));
    elseif strcmp(atlas, 'Destrieux')
        anatomicalLabel{labeli} = anatLabels.Destrieux(find(strcmp(anatLabels.Electrode, label{labeli})));
    end
end
end