%This functions assigns an anatomical label for a given channel position
%Project: ECoG_WM
%Author: D.T.
%Date: 28 September 2020

function chanIncluded = ECoG_getAnatomicalChannel(label, subject)

%Load data
anatLabels = readtable(['/media/darinka/Data0/iEEG/Results/Electrodes/' subject '/' subject '_elec_pos_final.xlsx']);

%Define search string
if strcmp(label, 'frontal')
    searchString = {'Frontal'};
elseif strcmp(label, 'temporal')
    searchString = {'Temporal',  'ippoc'};
end

%Extract all labels
for labeli = 1 : size(anatLabels, 1)
    if strcmp(label, 'temporal')
        if ~isempty(strfind(anatLabels.AFNI{labeli}, searchString{1})) | ~isempty(strfind(anatLabels.AFNI{labeli}, searchString{2})) 
            chanIncluded_AFNI{labeli} = anatLabels.Electrode{labeli};
        else
            chanIncluded_AFNI{labeli} = nan;
        end
    
        if ~isempty(strfind(anatLabels.AAL{labeli}, searchString{1})) | ~isempty(strfind(anatLabels.AAL{labeli}, searchString{2}))
            chanIncluded_AAL{labeli} = anatLabels.Electrode{labeli};
        else
            chanIncluded_AAL{labeli} = nan;
        end
    elseif strcmp(label, 'frontal')
        if strfind(anatLabels.AFNI{labeli}, searchString{1}) | strfind(anatLabels.AAL{labeli}, searchString{1})
            chanIncluded_AFNI{labeli} = anatLabels.Electrode{labeli};
        else
            chanIncluded_AFNI{labeli} = nan;
        end
    
        if ~isempty(strfind(anatLabels.AAL{labeli}, searchString{1})) 
            chanIncluded_AAL{labeli} = anatLabels.Electrode{labeli};
        else
            chanIncluded_AAL{labeli} = nan;
        end
    end
end

%Combine
for labeli = 1 : size(anatLabels, 1)
    if ~isnan(chanIncluded_AFNI{labeli}) | ~isnan(chanIncluded_AAL{labeli})
        chanIncluded{labeli} = anatLabels.Electrode{labeli};
    else
        chanIncluded{labeli} = [];
    end
end
end

% %Extract anatomical labels
% for labeli = 1 : length(label)
%     
%     if strcmp(atlas, 'AFNI')
%         anatomicalLabel{labeli} = anatLabels.AFNI(find(strcmp(anatLabels.Electrode, label{labeli})));
%     elseif strcmp(atlas, 'AAL')
%         anatomicalLabel{labeli} = anatLabels.AAL(find(strcmp(anatLabels.Electrode, label{labeli})));
%     elseif strcmp(atlas, 'BrainWeb')
%         anatomicalLabel{labeli} = anatLabels.BrainWeb(find(strcmp(anatLabels.Electrode, label{labeli})));
%     elseif strcmp(atlas, 'JuBrain')
%         anatomicalLabel{labeli} = anatLabels.JuBrain(find(strcmp(anatLabels.Electrode, label{labeli})));
%     elseif strcmp(atlas, 'VTPM')
%         anatomicalLabel{labeli} = anatLabels.VTPM(find(strcmp(anatLabels.Electrode, label{labeli})));
%     elseif strcmp(atlas, 'Brainnetome')
%         anatomicalLabel{labeli} = anatLabels.Brainnetome(find(strcmp(anatLabels.Electrode, label{labeli})));
%     elseif strcmp(atlas, 'Desikan_Killiany')
%         anatomicalLabel{labeli} = anatLabels.Desikan_Killiany(find(strcmp(anatLabels.Electrode, label{labeli})));
%     elseif strcmp(atlas, 'Destrieux')
%         anatomicalLabel{labeli} = anatLabels.Destrieux(find(strcmp(anatLabels.Electrode, label{labeli})));
%     end
% end
% end