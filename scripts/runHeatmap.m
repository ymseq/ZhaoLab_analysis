%%
clc;
clear;
addpath(genpath('./src'));
set(0, 'DefaultFigureVisible', 'on');


%%
params = setParams();
cords = loadData(params);

params.ana_tt = {'pattern_1','pattern_2','pattern_3', ...
                 'position_1','position_2','position_3'};
params.ana_bt = {'correct'};

fig_name = 'correct_all_rules.png';

cord = cords{4};
disp(cord.mice)
cord = alignReward(cord, params);
cord = pcaFit(cord, params);

reward_codes = [-1 0 1];
order_codes  = [-1 0 1];
order_w_idx  = arrayfun(@(rc) find(reward_codes==rc,1), order_codes);

sz = size(cord.ana_fr);

rows = cellfun(@(f) params.(f), params.ana_tt);
cols = cellfun(@(f) params.(f), params.ana_bt);
subs = 1:params.num_sub_type;

[R,C,S,L,W] = ndgrid(rows, cols, subs, 1:2, order_w_idx);
lin_idx = sub2ind(sz, R(:), C(:), S(:), L(:), W(:));

%%
cells_all = cord.ana_fr(lin_idx);                            % 线性取值（按期望顺序）
mask      = ~cellfun(@isempty, cells_all);                   % 非空
vecs      = cellfun(@(x) cord.denoise_matrix * mean(x,2), cells_all(mask), ...
                    'UniformOutput', false);                 % 每个 cell 展平成列向量
X = cat(2, vecs{:});

Rsel = R(:); Csel = C(:); Ssel = S(:); Lsel = L(:); Wsel = W(:);
Rsel = Rsel(mask); Csel = Csel(mask); Ssel = Ssel(mask); Lsel = Lsel(mask); Wsel = Wsel(mask);

labels = arrayfun(@(rr,cc,ss,ll,ww) ...
    sprintf('%s %s s%d l%d r%d', params.tt{rr},params.bt{cc},ss,ll,reward_codes(ww)), ...
    Rsel, Csel, Ssel, Lsel, Wsel, 'UniformOutput', false);

% align order_codes
grp_idx = arrayfun(@(w) find(order_w_idx==w,1), Wsel);
counts_per_group = accumarray(grp_idx(:), 1, [numel(order_w_idx), 1])';

% cal cosine
col_norms = sqrt(sum(X.^2,1)); col_norms(col_norms==0) = eps;
Xn = X ./ col_norms;
S  = Xn' * Xn;

% plot
figure('Color','w','Position', [100 100 1200 800]);
imagesc(S); axis image; colormap(parula); colorbar;
title('Cosine Similarity (ordered by reward: before(-1) → in(0) → after(1))');
xlabel('Samples'); ylabel('Samples');

% group lines
edges = cumsum(counts_per_group);
hold on;
arrayfun(@(e) xline(e+0.5,'k-','LineWidth',1), edges(1:end-1));
arrayfun(@(e) yline(e+0.5,'k-','LineWidth',1), edges(1:end-1));
hold off;

% label
n = size(S,1); step = 1;
set(gca,'TickLabelInterpreter','none');
xticks(1:step:n); yticks(1:step:n);
xticklabels(labels(1:step:end));
yticklabels(labels(1:step:end));

output_path = fullfile(params.save_path,'heatmap', params.task_type, cord.mice, fig_name);

fdir = fileparts(output_path);
if ~exist(fdir, 'dir')
    mkdir(fdir);
end

saveas(gcf, output_path);
