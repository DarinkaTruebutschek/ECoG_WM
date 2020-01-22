%% Plotting electrodes on surface example

% 1. Load the common brain
cortex_TemplateRight = load('/media/darinka/Data0/iEEG/ECoG_WM/Scripts/CurrentBrain/Colin_cortex_right.mat');
cortex_TemplateLeft = load('/media/darinka/Data0/iEEG/ECoG_WM/Scripts/CurrentBrain/Colin_cortex_left.mat');

%% Plot brain
% Define colormap
% you can play with that
M = 72;
G = fliplr(linspace(.8,1,M)) .';
cm = horzcat(G, G, G); 

cortex = cortex_TemplateRight.cortex;
a=tripatch(cortex, 1); 
shading interp;
a=get(gca);
d=a.CLim;
set(gca,'CLim',[-max(abs(d)) max(abs(d))])
l=light;
colormap(cm) 
lighting gouraud; % you can play with that
material([.2 .9 .15 10 1]); % you can play with that
axis off
set(gcf,'Renderer', 'zbuffer')
set(gcf,'color','w')

% Define view side 
% you can play with that
hemi = 'right';
viewside = 'lateral';
if strcmp(hemi,'left')
    switch viewside
        case 'lateral'
            th = 270;
            phi = 0;
        case 'medial'
            th = 90;
            phi = 0;
    end
elseif strcmp(hemi,'right')
    switch viewside
        case 'medial'
            th = 270;
            phi = 0;
        case 'lateral'
            th = 90;
            phi = 0;
    end
end
view(th, phi)

% Correct light
view(th,phi),
view_pt=[cosd(th-90)*cosd(phi) sind(th-90)*cosd(phi) sind(phi)];
a=get(gca,'Children');
for i=1:length(a)
    b=get(a(i));
    if strcmp(b.Type,'light') %find the correct child (the one that is the light)
        %object for light is the 2nd element, then use a 
        set(a(i),'Position',view_pt) 
        %or something
    end
end

%% Load electrodes
load('/media/darinka/Data0/iEEG/ECoG_WM/Scripts/CurrentBrain/elec_coord.mat');

%% Plot eletrodes
plot3(elec_coord(1:10,1),elec_coord(1:10,2),elec_coord(1:10,3), 'r.','MarkerSize', 50)



