%%
clc;
clear;
addpath(genpath('./src'));
set(0, 'DefaultFigureVisible', 'on');

%%
data_file = 'data/RA02-PFC.mat';

load(data_file, 'zones', 'simple_type', 'simple_firing', 'count_good')
count_good = count_good - 1;
cord = struct();

NUM_TIMES = 3100;
SPACE_UNIT = 0.1;

trial_type = cell(size(simple_type,1),1);
behavior_type = {'correct', 'false', 'miss'};

for i = 1:numel(trial_type)
    trial_type{i} = strtrim(simple_type(i,:));
end

for row = 1:numel(trial_type)
    for col = 1:numel(behavior_type)

        if ~isempty(simple_firing{row,col})
            fr_4d = simple_firing{row,col};
            fr_4d = fr_4d(1,:,:,1:NUM_TIMES);
            fr_4d = reshape(fr_4d,size(fr_4d,2),size(fr_4d,3),size(fr_4d,4));
            cord.(trial_type{row}).(behavior_type{col}).fr = fr_4d;
            cord.(trial_type{row}).(behavior_type{col}).num_trails = size(fr_4d,2);
        end

    end
end


%%

at = {'pattern_1','pattern_2','pattern_3', ...
      'position_1','position_2','position_3'};
ab = {'correct'};

total_trials = 0;

for i = 1:numel(at)
    for j = 1:numel(ab)
        total_trials = total_trials + cord.(at{i}).(ab{j}).num_trails;
    end
end


packed_fr = zeros(count_good,total_trials * NUM_TIMES);

idx = 0;
mean_group_fr = zeros(numel(at),numel(ab),count_good,NUM_TIMES);

for i = 1:numel(at)
    for j = 1:numel(ab)
        plus = cord.(at{i}).(ab{j}).num_trails * NUM_TIMES;
        packed_fr(:,idx+1:idx+plus) = reshape(cord.(at{i}).(ab{j}).fr, count_good, plus);
        idx = idx+plus;
        mean_group_fr(i,j,:,:) = mean(cord.(at{i}).(ab{j}).fr,2);
    end
end

packed_fr = permute(packed_fr,[2,1]);


%%

[coeff, score, latent, tsquared, explained, mu] = pca(packed_fr);



%%
plot_3d_projection(mean_group_fr, at, ab, coeff);


%%

function plot_3d_projection(mean_group_fr, at, ab, coeff)

    pc_vectors = coeff(:, 1:3);
    pc_vectors = permute(pc_vectors, [2,1]);

    colors = hsv(numel(at) * numel(ab));
    labels = cell(numel(at) * numel(ab),1);

    for i = 1:numel(at)
        for j = 1:numel(ab)

            figure;
            view(3);
            hold on;

            idx = j * (i - 1) + j;
            labels{idx} = [at{i},'_',ab{j}];

            fr = mean_group_fr(i,j,:,:);
            fr = squeeze(fr);
            time_window = 50;
            num_times = size(fr,2) / time_window;
            fr = mean(reshape(fr, [], time_window, num_times), 2);
            fr = squeeze(fr);
            pj = pc_vectors * fr;
            
            group_colors = repmat(colors(idx, :), num_times, 1);
            color_weights = linspace(0.3, 1, num_times)';
            group_colors = group_colors .* color_weights;
            
            plot3(pj(1,:), pj(2,:), pj(3,:), '-o', 'LineWidth', 0.5, 'MarkerSize', 6, 'Color', group_colors(1,:));
            scatter3(pj(1,:), pj(2,:), pj(3,:), 20, group_colors, 'filled');

            group_colors(1,:)

            title('Time Progression of the First 3 Principal Components');
            xlabel('PC1');
            ylabel('PC2');
            zlabel('PC3');
        
            hold off;

        end
    end
   

end




%%
function plot_explained_variance(explained)
    
    % Select the first 50 components (or fewer if there are less than 50)
    num_components = min(50, length(explained));
    explained_50 = explained(1:num_components);
    
    % Plot the explained variance as a line chart
    figure;
    plot(1:num_components, explained_50, '-o', 'LineWidth', 2);
    
    % Title and labels
    title('Explained Variance by the First 50 Principal Components');
    xlabel('Principal Components');
    ylabel('Explained Variance (%)');
    grid on;
    
    % Display a grid and adjust line style
    set(gca, 'FontSize', 12);
end























