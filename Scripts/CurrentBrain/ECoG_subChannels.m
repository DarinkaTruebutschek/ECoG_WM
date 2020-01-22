%%This function contains different configurations of channels according to
%%overall brain area.
%Project: ECoG_WM
%Author: D.T.
%Date: 16 December 2019

function channelSelection = ECoG_subChannels(subnip, brainArea)

if strcmp(subnip, 'MKL')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'FL*', 'FbL*', 'FbR*', 'FR*', 'FlR*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{'FL*', 'FbL*'}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{'FbR*', 'FR*', 'FlR*'}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end
    
elseif strcmp(subnip, 'EG_I')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'FAL*', 'FBL*', 'FLL*', 'FAR*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{'FAL*', 'FBL*', 'FLL*'}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{'FAR*'}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end

elseif strcmp(subnip, 'HS')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'FLR*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{'FLR*'}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{'AHL*', 'DHL*', 'TBOR*', 'TBPR*', 'TBAR*', 'TLR*'}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{'AHL*', 'DHL*'}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{'TBOR*', 'TBPR*', 'TBAR*', 'TLR*'}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end

elseif strcmp(subnip, 'MG')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'FL*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{'FL*'}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{'TLS*', 'TLI*', 'CA*', 'HIP*', 'TBP*'}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{'TLS*', 'TLI*', 'CA*', 'HIP*', 'TBP*'}};
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{'CP*'}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{'CP*'}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{'OB1*'}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{'OB1*'}};
    end
    
elseif strcmp(subnip, 'KR')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'FL*', 'FLR*', 'FPR*', 'FAR*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{'FL*'}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{'FLR*', 'FPR*', 'FAR*'}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{'TAR*', 'THR*'}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{'TAR*', 'THR*'}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end

elseif strcmp(subnip, 'WS')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'FLL*', 'FBR*', 'FLR*', 'IAR*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{'FLL*'}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{'FBR*', 'FLR*', 'IAR*'}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{'TSR*', 'HKR*'}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{'TSR*', 'HKR*'}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end
    
elseif strcmp(subnip, 'KJ_I')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'FLR*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{'FLR*'}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{'TLR*', 'TIA*', 'TIM*', 'TIP*'}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{'TLR*', 'TIA*', 'TIM*', 'TIP*'}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{'PLR*'}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{'PLR*'}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end    

elseif strcmp(subnip, 'LJ')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'LFM*', 'LFL*', 'LFB*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{'LFM*', 'LFL*', 'LFB*'}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{''}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{'CA*', 'HIP*', 'LTA*', 'LPS*'}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{'CA*', 'HIP*', 'LTA*', 'LPS*'}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end

elseif strcmp(subnip, 'AS')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'FL*', 'FPL*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{'FL*', 'FPL*'}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{''}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end
    
elseif strcmp(subnip, 'SB')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{'FAL*', 'FR*'}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{'FAL*'}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{'FR*'}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end
    
elseif strcmp(subnip, 'AP')
    if strcmp(brainArea, 'frontal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'frontal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'frontal_r')
        channelSelection = {{''}}';  
    elseif strcmp(brainArea, 'temporal_bl')
        channelSelection = {{'TLL*', 'TAL*', 'TPL*', 'TLR*', 'TAR*', 'TMR*', 'TPR*'}}';
    elseif strcmp(brainArea, 'temporal_l')
        channelSelection = {{'TLL*', 'TAL*', 'TPL*'}}';
    elseif strcmp(brainArea, 'temporal_r')
        channelSelection = {{'TLR*', 'TAR*', 'TMR*', 'TPR*'}}';
    elseif strcmp(brainArea, 'parietal_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'parietal_r')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_bl')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_l')
        channelSelection = {{''}}';
    elseif strcmp(brainArea, 'occipital_r')
        channelSelection = {{''}};
    end
end
