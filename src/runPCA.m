%%
clc;
clear;
addpath(genpath('./src'));
set(0, 'DefaultFigureVisible', 'on');


%%
params = setParams();
cords = loadData(params);


cord = cords{1};
cord = preprocessFr(cord, params);
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

        xlines = [xlines; xline];
        ylines = [ylines; yline];
        zlines = [zlines; zline];

        base_label = [tt{row} '_' bt{col}];
        label = repmat({base_label}, num_repeats, 1);
        lineLabels = [lineLabels; label];

        base_color = colors(row, col, :);
        color = repmat(base_color, num_repeats, 1);
        lineColors = [lineColors; color];
        
    end
end

%%

plot3D_2(xlines, ylines, zlines, lineColors, lineLabels, params);

%%

% %%
% vecs = cord.pcs(:,1:3);
% tnames = {'pattern_1','pattern_2','pattern_3', ...
%           'position_1','position_2','position_3'};
% bname = 'correct';
% 
% plot3D(vecs, tnames, bname, cord, params, 1);
% 
% 
% vecs = cord.pcs(:,1:3);
% tnames = {'pattern_1','pattern_3', ...
%           'position_1','position_2','position_3'};
% bname = 'false';
% 
% plot3D(vecs, tnames, bname, cord, params, 1);

% for idx = 1:numel(cords)
% 
%     cord = cords{idx};
%     cord = preprocessFr(cord, params);
%     cord = pcaFit(cord, params);
% 
% 
%     vecs = cord.pcs(:,1:3);
%     tnames = {'pattern_1','pattern_2','pattern_3', ...
%               'position_1','position_2','position_3'};
%     bname = 'correct';
% 
%     plot3D(vecs, tnames, bname, cord, params, 1);
% 
% 
%     vecs = cord.pcs(:,1:3);
%     tnames = {'pattern_1','pattern_3', ...
%               'position_1','position_2','position_3'};
%     bname = 'false';
% 
%     plot3D(vecs, tnames, bname, cord, params, 1);
% 
% end
