%%
clc;
clear;
addpath(genpath('./src'));
set(0, 'DefaultFigureVisible', 'on');


%%
params = setParams();
cords = loadData(params);

cord = cords{6};

cord = alignLick(cord, params);
cord = pcaFit(cord, params);

vecs = cord.pcs(:,1:3);
x_vec = reshape(vecs(:,1),1,[]);
y_vec = reshape(vecs(:,2),1,[]);
z_vec = reshape(vecs(:,3),1,[]);

len_r = numel(params.ana_tt);
len_c = numel(params.ana_bt);
len_s = params.num_sub_type;
len_l = 2;

[C, R, S, L] = ndgrid(1:len_r, 1:len_c, 1:len_s, 1:len_l);
combinations = [C(:), R(:), S(:), L(:)];
num_combinations = size(combinations, 1);

colors = jet(num_combinations);
colors = reshape(colors,len_r,len_c,len_s,len_l,[]);

lineColors = {};
lineLabels = {};
xlines = {};
ylines = {};
zlines = {};

for i = 1:num_combinations

    id1 = combinations(i, 1);
    id2 = combinations(i, 2);
    s = combinations(i, 3);
    l = combinations(i, 4);

    row = params.(params.ana_tt{id1});
    col = params.(params.ana_bt{id2});
    
    if isempty(cord.ana_fr{row, col, s, l})
        continue;
    end
    fr = cord.ana_fr{row, col, s, l};
    
    xline = x_vec * fr;
    yline = y_vec * fr;
    zline = z_vec * fr;
    xline = reshape(xline, [], params.len_lick);
    yline = reshape(yline, [], params.len_lick);
    zline = reshape(zline, [], params.len_lick);
    
    xlines{end+1} = xline;
    ylines{end+1} = yline;
    zlines{end+1} = zline;
    
    label = sprintf('%s_%s_sub%d_lick%d', ...
        params.ana_tt{id1}, params.ana_bt{id2}, s, l);
    lineLabels{end+1} = label;
    
    color = colors(id1,id2,s,l,:);
    lineColors{end+1} = color;

    % if strcmp(params.ana_bt{id2}, 'correct')
    %     lineColors{end+1} = [1, 0, 0];
    % else
    %     lineColors{end+1} = [0, 0, 1];
    % end
end


%%

plot3D_2(xlines, ylines, zlines, lineColors, lineLabels, params);


