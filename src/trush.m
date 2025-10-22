function cord = limitProcess(cord, params)
% only take the analyzed trials, then average within repeat trial first, 
% then do gaussian smooth and normalize

    len_r = numel(params.ana_tt);
    len_c = numel(params.ana_bt);

    ana_fr = cell(numel(params.tt), numel(params.bt));

    num_ana_fr_sum = 0;

    for id1 = 1:len_r
        for id2 = 1:len_c
            row = params.(params.ana_tt{id1});
            col = params.(params.ana_bt{id2});
            if isempty(cord.simple_firing{row,col})
                continue;
            end

            % average within conditions
            fr = cord.simple_firing{row,col};
            fr = mean(fr,3);
            fr = squeeze(fr);

            % gaussian kernel smoothing
            kernel = fspecial('gaussian', [1, params.gaussian_range], params.gaussian_sigma);
            for i = 1:size(fr,1)
                fr(i, :) = conv(fr(i, :), kernel, 'same');
            end

            % clip
            fr = fr(:,params.left_boundary_idx:params.right_boundary_idx);

            ana_fr{row,col} = fr;

            % cal whole fr of units
            num_ana_fr_sum = num_ana_fr_sum + size(fr,2);
        end
    end

    ana_fr_sum = zeros(cord.num_neurons, num_ana_fr_sum);

    sum_idx = 0;
    for id1 = 1:len_r
        for id2 = 1:len_c
            row = params.(params.ana_tt{id1});
            col = params.(params.ana_bt{id2});
            if isempty(ana_fr{row,col})
                continue;
            end

            fr = ana_fr{row,col};
            plus = params.len_trial;
            ana_fr_sum(:,(sum_idx + 1):(sum_idx + plus)) = fr;
            sum_idx = sum_idx + plus;

        end
    end

    mean_units = mean(ana_fr_sum, 2);
    std_units = std(ana_fr_sum, 0, 2);

    ana_fr_sum = (ana_fr_sum - mean_units) ./ std_units;

    for id1 = 1:len_r
        for id2 = 1:len_c
            row = params.(params.ana_tt{id1});
            col = params.(params.ana_bt{id2});
            if isempty(ana_fr{row,col})
                continue;
            end
            ana_fr{row,col} = (ana_fr{row,col} - mean_units) ./ std_units;
        end
    end

    cord.ana_fr = ana_fr;
    cord.ana_fr_sum = ana_fr_sum;
    
end



function cord = preprocessFr(cord,params)

    rows = cellfun(@(f) params.(f), params.tt);
    cols = cellfun(@(f) params.(f), params.bt);

    processed_fr = cell(numel(params.tt), numel(params.bt));

    g1d = fspecial('gaussian', [1 params.gaussian_range], params.gaussian_sigma);  % 1 x K
    g3d = reshape(g1d, 1, 1, []);  % 1 x 1 x K

    blocks = {};
    blocks_idx = 1;

    for r = rows
        for c = cols
            fr = cord.simple_firing{r, c};
            if isempty(fr), continue; end
    
            % [N x Trials x len_total]
            fr = reshape(fr,size(fr,2),size(fr,3),size(fr,4));
    
            % gaussian smooth
            fr = convn(fr, g3d, 'same');
    
            % clip, [N x Trials x len_trial]
            fr = fr(:, :, params.left_boundary_idx : params.right_boundary_idx);
    
            processed_fr{r,c} = fr;
    
            % flatten
            fr_block = reshape(fr, size(fr,1), []);
            blocks{blocks_idx} = fr_block;
            blocks_idx = blocks_idx + 1;
        end
    end

    fr_sum = [blocks{:}];

    mu  = mean(fr_sum, 2);
    sg  = std(fr_sum, 0, 2);
    sg  = max(sg, eps);
    
    mu3 = reshape(mu, [], 1, 1);
    sg3 = reshape(sg, [], 1, 1);
    
    mask = ~cellfun('isempty', processed_fr);
    processed_fr(mask) = cellfun(@(x) (x - mu3) ./ sg3, processed_fr(mask), ...
                                 'UniformOutput', false);

    cord.processed_fr = processed_fr;

end

function cord = linearFit(cord, params)

    % reconstruct the matrix
    % fr: N_units * (N_times *N_conditions)
    fr = cord.ana_fr_sum;
    % fr: N_units * (N_times / 5) * (5 * N_conditions)
    fr = reshape(fr,size(fr,1),params.len_sub_trial, []);

    len_r = numel(params.ana_tt);
    len_c = numel(params.ana_bt);

    % var_matrix: (5 * N_conditions) * 3 var
    % position (1 to 5), choice (1 or -1), cross fig (1 or -1)
    var_matrix = zeros(size(fr,3),3);
    sum_idx = 0;
    for id1 = 1:len_r
        for id2 = 1:len_c
            row = params.(params.ana_tt{id1});
            col = params.(params.ana_bt{id2});
            if isempty(cord.processed_fr{row,col})
                continue;
            end
            trial_type = params.tt{row};
            behavior_type = params.bt{col};

            var_unit = zeros(5, 3);
            switch trial_type
                case 'origin'
                    var_unit(1,:) = [1,-1,-1];
                    var_unit(2,:) = [2,-1,-1];
                    var_unit(3,:) = [3,1,1];
                    var_unit(4,:) = [4,-1,-1];
                    var_unit(5,:) = [5,-1,-1];
                case 'pattern_1'
                    var_unit(1,:) = [1,1,1];
                    var_unit(2,:) = [2,-1,-1];
                    var_unit(3,:) = [3,-1,-1];
                    var_unit(4,:) = [4,-1,-1];
                    var_unit(5,:) = [5,-1,-1];
                case 'pattern_2'
                    var_unit(1,:) = [1,-1,-1];
                    var_unit(2,:) = [2,-1,-1];
                    var_unit(3,:) = [3,1,1];
                    var_unit(4,:) = [4,-1,-1];
                    var_unit(5,:) = [5,-1,-1];
                case 'pattern_3'
                    var_unit(1,:) = [1,-1,-1];
                    var_unit(2,:) = [2,-1,-1];
                    var_unit(3,:) = [3,-1,-1];
                    var_unit(4,:) = [4,-1,-1];
                    var_unit(5,:) = [5,1,1];
                case 'position_1'
                    var_unit(1,:) = [1,-1,1];
                    var_unit(2,:) = [2,-1,-1];
                    var_unit(3,:) = [3,1,-1];
                    var_unit(4,:) = [4,-1,-1];
                    var_unit(5,:) = [5,-1,-1];
                case 'position_2'
                    var_unit(1,:) = [1,-1,-1];
                    var_unit(2,:) = [2,-1,-1];
                    var_unit(3,:) = [3,1,1];
                    var_unit(4,:) = [4,-1,-1];
                    var_unit(5,:) = [5,-1,-1];
                case 'position_3'
                    var_unit(1,:) = [1,-1,-1];
                    var_unit(2,:) = [2,-1,-1];
                    var_unit(3,:) = [3,1,-1];
                    var_unit(4,:) = [4,-1,-1];
                    var_unit(5,:) = [5,-1,1];
            end

            var_matrix((sum_idx + 1):(sum_idx + 5),:) = var_unit;

        end
    end

    var_matrix = [var_matrix, ones(size(var_matrix,1),1)];

    betas = zeros(cord.num_neurons, params.len_sub_trial, size(var_matrix,2));

    for i = 1:cord.num_neurons
        for t = 1:params.len_sub_trial
            y = squeeze(fr(i,t,:));
            b = var_matrix \ y;
            betas(i,t,:) = b;
        end
    end

    betas = pagemtimes(cord.denoise_matrix, betas);

    num_var = size(betas,3);
    max_betas = zeros(cord.num_neurons, num_var);
    for v = 1:num_var
        norms = zeros(1, params.len_sub_trial);
        for t = 1:params.len_sub_trial
            vec = squeeze(betas(:,t,v));
            norms(t) = norm(vec, 2);
        end
        [~, t_max] = max(norms);
        max_betas(:,v) = betas(:,t_max,v);
    end
    [Q_matrix, ~] = qr(max_betas, 0);
    
    cord.betas = betas;
    cord.Q_matrix = Q_matrix;

end



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
%     cord = limitprocess(cord, params);
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


%%
clc;
clear;
addpath(genpath('./src'));
set(0, 'DefaultFigureVisible', 'on');


%%
params = setParams();
cords = loadData(params);

cord = cords{6};
cord = alignTrack(cord, params);
cord = pcaFit(cord, params);

vecs = cord.pcs(:,1:3);
x_vec = reshape(vecs(:,1),1,[]);
y_vec = reshape(vecs(:,2),1,[]);
z_vec = reshape(vecs(:,3),1,[]);

cord = alignLick(cord, params);
cord = pcaFit(cord, params);

len_r = numel(params.ana_tt);
len_c = numel(params.ana_bt);
len_s = params.num_sub_type;
len_l = 1;

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



