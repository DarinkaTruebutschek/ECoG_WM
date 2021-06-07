clear all
close all
clc

sub_deets{1}.iEEG = 'AP_erp_100';
sub_deets{1}.behav = 'AP_memory_behavior_forPython_final';

sub_deets{2}.iEEG = 'AS_erp_100';
sub_deets{2}.behav = 'AS_memory_behavior_forPython_final';

sub_deets{3}.iEEG = 'EG_I_erp_100';
sub_deets{3}.behav = 'EG_I_memory_behavior_forPython_final';

sub_deets{4}.iEEG = 'HS_erp_100';
sub_deets{4}.behav = 'HS_memory_behavior_forPython_final';

sub_deets{5}.iEEG = 'KJ_I_erp_100';
sub_deets{5}.behav = 'KJ_I_memory_behavior_forPython_final';

sub_deets{6}.iEEG = 'KR_erp_100';
sub_deets{6}.behav = 'KR_memory_behavior_forPython_final';

sub_deets{7}.iEEG = 'LJ_erp_100';
sub_deets{7}.behav = 'LJ_memory_behavior_forPython_final';

sub_deets{8}.iEEG = 'MG_erp_100';
sub_deets{8}.behav = 'MG_memory_behavior_forPython_final';

sub_deets{9}.iEEG = 'MKL_erp_100';
sub_deets{9}.behav = 'MKL_memory_behavior_forPython_final';

sub_deets{10}.iEEG = 'SB_erp_100';
sub_deets{10}.behav = 'SB_memory_behavior_forPython_final';

sub_deets{11}.iEEG = 'WS_erp_100';
sub_deets{11}.behav = 'WS_memory_behavior_forPython_final';

nsubs = length(sub_deets);
data_dir = '/Users/markstokes/Dropbox (Attention Group)/Attention Group Team Folder/Darinka/iEEG for Mark/';
subD = zeros(nsubs,10,10);
xd = zeros(20,20);
for i=1:20
    for j=1:20
        if i~=j
            xd(i,j) = 2;
            
            if mod(i,10)==mod(j,10)
                xd(i,j) = 1;
            end
        end
    end
end

xd=xd(:);

for s = 1:nsubs
    disp(s)
    load(fullfile(data_dir,sub_deets{s}.iEEG))
    load(fullfile(data_dir,sub_deets{s}.behav))
    
    %% get condition list
    stimA = table_struct.data{1,8} + 1; % identify of stim A only
    ind = table_struct.data{1,17}==1; % select 'good' trials
    stimA = stimA(ind);    
    
    %% get in matrix form
    dat = zeros(length(data.trial),size(data.trial{1},1),size(data.trial{1},2));
    
    for i=1:length(data.trial)
        dat(i,:,:) = data.trial{i};
    end
    
    %% average stimulus subconditions
    x=zeros(10,size(dat,2),size(dat,3));
    
    for i=1:10
        ind = stimA == i;
        x(i,:,:) = squeeze(mean(dat(ind,:,:),1));
    end
    
    %% average time window
    t_ind = data.time{1}>1.73 & data.time{1}<2.37; % time of interest
    x1 = squeeze(mean(x(:,:,t_ind),3));
    %% caculate distance
    d=squareform(pdist(x1));
    %%
    subD(s,:,:) = d; 
    
end

%% plot results
close all
Y = mdscale(squeeze(mean(subD,1)),2);

figure, scatter(Y(:,1),Y(:,2),'.'), hold on

a = [1:10]'; b = num2str(a); c = cellstr(b);
dx = 0.0; dy = 0.0; % displacement so the text does not overlay the data points
text(Y(:,1)+dx, Y(:,2)+dy, c);


