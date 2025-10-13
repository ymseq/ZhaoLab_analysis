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

len_r = numel(params.ana_tt);
len_c = numel(params.ana_bt);

colors = jet(len_r * len_c);
colors = reshape(colors, len_r, len_c, 3);

lineColors = [];
lineLabels = {};
xlines = [];
ylines = [];
zlines = [];

for id1 = 1:numel(params.ana_tt)
    for id2 = 1:numel(params.ana_bt)
        row = params.(params.ana_tt{id1});
        col = params.(params.ana_bt{id2});
        if isempty(cord.processed_fr{row,col})
            continue;
        end

        fr = cord.processed_fr{row,col};
        
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

        base_label = [params.ana_tt{id1} '_' params.ana_bt{id2}];
        label = repmat({base_label}, num_repeats, 1);
        lineLabels = [lineLabels; label];

        base_color = colors(id1, id2, :);
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

