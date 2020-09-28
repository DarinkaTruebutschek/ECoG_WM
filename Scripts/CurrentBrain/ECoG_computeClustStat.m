%This functions performs a cluster-based permutation test to compute
%statistical significance.
%Project: ECoG_WM
%Author: D.T.
%Date: 25 September 2020

function stats = ECoG_computeClustStat(cond1, cond2, timeWin, freqWin, designType, subi)

stats = [];

%Prepare the neighbor file
if strcmp(designType, 'within-subject')
    cfg = [];
    cfg.method = 'distance';
    
    if subi == 1
        cfg.neighbourdist = 8; %this is an arbitrary value, so neighbor definition has to be checked very carefully
    elseif subi == 2
        cfg.neighbourdist = 12;
    elseif subi == 3
        cfg.neighbourdist = 16;
    elseif subi == 4
        cfg.neighbourdist = 8;
    elseif subi == 5
        cfg.neighbourdist = 16;
    elseif subi == 6
        cfg.neighbourdist = 8;
    elseif subi == 7
        cfg.neighbourdist = 8;
    elseif subi == 8
        cfg.neighbourdist = 10;
    elseif subi == 9
        cfg.neighbourdist = 9;
    elseif subi == 10
        cfg.neighbourdist = 12;
    elseif subi == 11
        cfg.neighbourdist = 12;
    end
       
    cfg.elec = cond1.freq_cond.elec;
    cfg.feedback = 'no';
    
    neighbors = ft_prepare_neighbours(cfg, cond1.freq_cond);
end

%Prepare the design file
if strcmp(designType, 'within-subject')
    cond_design = zeros(1, size(cond1.freq_cond.powspctrm, 1) + size(cond2.freq_cond.powspctrm, 1));
    cond_design(1, 1: size(cond1.freq_cond.powspctrm, 1)) = 1;
    cond_design(1, (size(cond1.freq_cond.powspctrm, 1)+1) : (size(cond1.freq_cond.powspctrm, 1) + ...
        size(cond2.freq_cond.powspctrm, 1))) = 2;
end

%Compute stats
cfg = [];

if strcmp(freqWin, 'all')
    cfg.frequency = 'all';
else
    cfg.frequency = freqWin;
    cfg.avgoverfreq = 'yes';
end

cfg.channel = 'all';
cfg.latency = timeWin;

cfg.method = 'montecarlo';

if strcmp(designType, 'within-subject')
    cfg.statistic = 'ft_statfun_indepsamplesT';
end

cfg.correctm = 'cluster';
cfg.clusteralpha = .05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan = 0;
cfg.tail = 0; %two-tailed test
cfg.clustertail = 0;
cfg.alpha = .025;
cfg.numrandomization = 1000;
cfg.neighbours = neighbors;

cfg.design = cond_design;
cfg.ivar = 1;

stats = ft_freqstatistics(cfg, cond1.freq_cond, cond2.freq_cond);
end
