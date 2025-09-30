function plotDeduce(cord,params)

    position_vector = cord.Q_matrix(:,1)';
    choice_vector = cord.Q_matrix(:,2)';
    cross_fig_vector = cord.Q_matrix(:,3)';

    trial_types = {'pattern_1','pattern_2','pattern_3'};
    % trial_types = {'position_1','position_2','position_3'};
    trial_pos_v = zeros(numel(trial_types),params.len_sub_trial,5);
    trial_choice_v = zeros(numel(trial_types),params.len_sub_trial,5);
    for idx = 1:numel(trial_types)
        typename = trial_types{idx};
        fr = cord.processed_fr{params.(typename),params.correct};
        fr = reshape(fr,size(fr,1),params.len_sub_trial,5);

        trial_pos_v(idx,:,:) = squeeze(pagemtimes(position_vector,fr));
        trial_choice_v(idx,:,:) = squeeze(pagemtimes(choice_vector,fr));
    end

    trial_pos_v = squeeze(mean(trial_pos_v, 1));
    trial_choice_v = squeeze(mean(trial_choice_v, 1));

    h = figure; hold on;
    h.Units    = 'pixels';
    h.Position = [200 200 800 600];
    ax = gca;
    ax.FontSize   = 18;
    grid off;

    ax.ColorOrder = lines(5);

    for k = 1:5
        xk = trial_choice_v(:, k);
        yk = trial_pos_v(:, k);
        plot(xk, yk, 'LineWidth', 2, 'DisplayName', sprintf('position %d', k));
    end

    xlabel('choice');
    ylabel('position');
    title('Pattern rule');
    legend('show', 'Location', 'best');

    trial_types = {'pattern_1','pattern_2','pattern_3'};
    % trial_types = {'position_1','position_2','position_3'};
    trial_cf_v1 = zeros(numel(trial_types),200,1);
    trial_cf_v4 = zeros(numel(trial_types),200,4);
    trial_choice_v1 = zeros(numel(trial_types),200,1);
    trial_choice_v4 = zeros(numel(trial_types),200,4);
    for idx = 1:numel(trial_types)
        typename = trial_types{idx};
        fr = cord.processed_fr{params.(typename),params.correct};
        fr = reshape(fr,size(fr,1),params.len_sub_trial,5);
        fr = fr(:,301:500,:);

        temp_cf_v = squeeze(pagemtimes(cross_fig_vector,fr));
        temp_ch_v = squeeze(pagemtimes(choice_vector,fr));

        switch idx
            case 1
                trial_cf_v1(idx,:,:) = temp_cf_v(:,1);
                trial_choice_v1(idx,:,:) = temp_ch_v(:,1);
                trial_cf_v4(idx,:,:) = temp_cf_v(:,2:5);
                trial_choice_v4(idx,:,:) = temp_ch_v(:,2:5);
            case 3
                trial_cf_v1(idx,:,:) = temp_cf_v(:,3);
                trial_choice_v1(idx,:,:) = temp_ch_v(:,3);
                trial_cf_v4(idx,:,1:2) = temp_cf_v(:,1:2);
                trial_cf_v4(idx,:,3:4) = temp_cf_v(:,4:5);
                trial_choice_v4(idx,:,1:2) = temp_ch_v(:,1:2);
                trial_choice_v4(idx,:,3:4) = temp_ch_v(:,4:5);
            case 4
                trial_cf_v1(idx,:,:) = temp_cf_v(:,5);
                trial_choice_v1(idx,:,:) = temp_ch_v(:,5);
                trial_cf_v4(idx,:,:) = temp_cf_v(:,1:4);
                trial_choice_v4(idx,:,:) = temp_ch_v(:,1:4);
        end

    end

    trial_cf_v1 = squeeze(mean(trial_cf_v1,[1 3]));
    trial_cf_v4 = squeeze(mean(trial_cf_v4,[1 3]));
    trial_choice_v1 = squeeze(mean(trial_choice_v1,[1 3]));
    trial_choice_v4 = squeeze(mean(trial_choice_v4,[1 3]));

    h = figure; hold on;
    h.Units    = 'pixels';
    h.Position = [200 200 800 600];
    ax = gca;
    ax.FontSize   = 18;
    grid off;

    ax.ColorOrder = lines(2);

    plot(trial_choice_v1, trial_cf_v1, 'LineWidth', 2, 'DisplayName', 'fig on');
    plot(trial_choice_v4, trial_cf_v4, 'LineWidth', 2, 'DisplayName', 'fig off');

    xlabel('choice');
    ylabel('cross fig');
    title('Pattern rule');
    legend('show', 'Location', 'best');

end

