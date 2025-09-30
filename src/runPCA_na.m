%%
clc;
clear;
addpath(genpath('./src'));
set(0, 'DefaultFigureVisible', 'on');


%%
params = setParams();
cords = loadData(params);


cord = cords{1};
cord = preprocessFr_na(cord, params);
cord = pcaFit(cord, params);


vecs = cord.pcs(:,1:3);
x_vec = reshape(vecs(:,1),1,[]);
y_vec = reshape(vecs(:,2),1,[]);
z_vec = reshape(vecs(:,3),1,[]);

tt = cord.trial_types;
bt = cord.behavior_types;

len_r = numel(tt);
len_c = numel(bt);

colors = jet(len_r * len_c);
colors = reshape(colors, len_r, len_c, 3);

lineColors = [];
lineLabels = {};
xlines = [];
ylines = [];
zlines = [];

for row = 1:len_r
    for col = 1:len_c
        fr = cord.processed_fr{row,col};
        if isempty(fr)
            continue;
        end
        
        xline = x_vec * fr;
        yline = y_vec * fr;
        zline = z_vec * fr;

        xline = reshape(xline, [], params.len_trial);
        yline = reshape(yline, [], params.len_trial);
        zline = reshape(zline, [], params.len_trial);

        xline = reshape(xline, [], params.len_trial);
        yline = reshape(yline, [], params.len_trial);
        zline = reshape(zline, [], params.len_trial);

        num_repeats = size(xline, 1);

        xlines = [xlines; xline(1,:)];
        ylines = [ylines; yline(1,:)];
        zlines = [zlines; zline(1,:)];

        base_label = [tt{row} '_' bt{col}];
        label = repmat({base_label}, num_repeats, 1);
        lineLabels = [lineLabels; label(1,:)];

        base_color = colors(row, col, :);
        color = repmat(base_color, num_repeats, 1);
        lineColors = [lineColors; color(1,:)];
        
    end
end

%%

plot3D_na(xlines, ylines, zlines, lineColors, lineLabels, params);


%%

% sub = 23;
% plot3D_na(xlines(sub,:), ylines(sub,:), zlines(sub,:), lineColors(sub,:), lineLabels(sub,:), params);