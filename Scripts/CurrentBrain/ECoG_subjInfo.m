%This script contains the electrode information for each subject.
%Project: ECoG_WM
%Author: D.T.
%Date: 20 September 2019

function [channels_left, channels_right] = ECoG_subjInfo(subnip, elecType)

switch char(subnip)
    case 'MKL'
        switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {};
            case 'depth'
                channels_left = {'FbL*', 'FL*'};
                channels_right = {'FbR*', 'FR*', 'FlR*'};
        end
    case 'EG_I'
       switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {};
            case 'depth'
                channels_left = {'FAL*', 'FBL*', 'FLL*'};
                channels_right = {'FAR*'};
       end
    case 'HS'
       switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {'FLR*', 'TLR*', 'TBAR*', 'TBMR*', 'TBPR*', 'TBOR*'};
            case 'depth'
                channels_left = {'DHL*', 'AHL*'};
                channels_right = {};      
       end
    case 'MG'
        switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {'CP*', 'FL*', 'TLS*', 'TLI*', 'CA*', 'HIP*', 'TBP*', 'OB*'};
            case 'depth'
                channels_left = {};
                channels_right = {};
        end
    case 'KR'
         switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {};
            case 'depth'
                channels_left = {'FL*'};
                channels_right = {'FIR*', 'TAR*', 'THR*', 'FAR*', 'FPR*'};       
         end
    case 'WS'
         switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {};
            case 'depth'
                channels_left = {'FLL*'};
                channels_right = {'FBR*', 'FLR*', 'IAR*', 'TSR*', 'HKR*'};   
         end
    case 'KJ_I'
         switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {'FLR*', 'PLR*', 'TLR*', 'TIA*', 'TIM*', 'TIP*'};
            case 'depth'
                channels_left = {};
                channels_right = {}; 
         end
    case 'LJ'
         switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {};
            case 'depth'
                channels_left = {'LFL*', 'LFM*', 'CA*', 'LTA*', 'HIP*', 'LPS*', 'LFB*'};
                channels_right = {};        
         end
    case 'AS'
          switch char(elecType)
            case 'grid'
                channels_left = {'FPL*', 'FL*'};
                channels_right = {};
            case 'depth'
                channels_left = {};
                channels_right = {};     
          end
    case 'SB'
           switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {};
            case 'depth'
                channels_left = {'FAL*'};
                channels_right = {'FR*'};     
           end      
    case 'HL'
           switch char(elecType)
            case 'grid'
                channels_left = {};
                channels_right = {};
            case 'depth'
                channels_left = {'MEL*'};
                channels_right = {'BAR*', 'ALR*', 'PLR*', 'MER*', 'SMR*'};  
           end
    case 'AP'
           switch char(elecType)
            case 'grid'
                channels_left = {'TLL*', 'TAL*', 'TPL*'};
                channels_right = {'TLR*', 'TAR*', 'TMR*', 'TPR*'};
            case 'depth'
                channels_left = {};
                channels_right = {};       
           end
end
end