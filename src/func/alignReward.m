function cord = alignReward(cord,params)

    %% preprocess whole data
    rows = cellfun(@(f) params.(f), params.tt);
    cols = cellfun(@(f) params.(f), params.bt);

    processed_fr = cell(numel(params.tt), numel(params.bt), ...
                    params.num_sub_type, params.num_lick_type,params.num_reward_type);

    g1d = fspecial('gaussian', [1 params.gaussian_range], params.gaussian_sigma);
    g3d = reshape(g1d, 1, 1, []);  % 1 x 1 x K

    blocks = {};

    for r = rows
        for c = cols
            fr = cord.simple_firing{r, c};
            if isempty(fr), continue; end
    
            % [N x trials x len_all]
            fr = reshape(fr, size(fr,2), size(fr,3), size(fr,4));
    
            % gaussian smooth
            fr = convn(fr, g3d, 'same');
    
            for id_sub = 1:params.num_sub_type
                sub_bound = cord.zones(id_sub,:);
                pos_lick_trials = cord.pos_lick_type{r,c};
                pos_reward_trials = cord.pos_reward_type{r,c};
    
                sub_fr_trials = zeros(cord.num_neurons, size(fr,2), params.len_lick);
                % sub_fr_trials = zeros(cord.num_neurons, size(fr,2), 241);
                lick_type_trials = zeros(1,size(fr,2));
                reward_type_trials = zeros(1,size(fr,2));
    
                for id_trial = 1:size(fr,2)
    
                    start_pos = sub_bound(1) + params.len_before_lick * params.space_unit;
                    lick_type = 0;
    
                    if isa(pos_lick_trials, 'cell')
                        pos_lick = pos_lick_trials{id_trial};
                    elseif isempty(pos_lick_trials)
                        pos_lick = [];
                    elseif isa(pos_lick_trials, 'double') && size(fr,2)==1
                        pos_lick = squeeze(pos_lick_trials);
                    else
                        error('Unkown structure of pos_lick_type');
                    end
    
                    if isempty(pos_reward_trials)
                        record_pos_reward = [];
                    elseif isa(pos_reward_trials, 'double')
                        record_pos_reward = pos_reward_trials(id_trial);
                    elseif isa(pos_reward_trials, 'cell')
                        record_pos_reward = pos_reward_trials{id_trial};
                    else
                        error('Unkown structure of pos_reward_type');
                    end
                    
                    for i = 1:numel(pos_lick)
                        if sub_bound(1) <= pos_lick(i) && pos_lick(i) <= sub_bound(2)
                            start_pos = pos_lick(i);
                            lick_type = 1;
                            break;
                        end
                    end

                    pos_reward = [];
                    for i = 1:numel(record_pos_reward)
                        if ~isempty(pos_reward)
                            break;
                        end
                        % for j = 1:numel(size(cord.zones,1))
                        %     temp_bound = cord.zones(j,:);
                        %     if temp_bound(1) <= record_pos_reward(i) && record_pos_reward(i) <= temp_bound(2)
                        %         pos_reward = record_pos_reward(i);
                        %         break;
                        %     end
                        % end
                        left = params.left_track_idx * params.space_unit;
                        right = params.right_track_idx * params.space_unit;
                        if left <= record_pos_reward(i) && record_pos_reward(i)<= right
                            pos_reward = record_pos_reward(i);
                        end
                    end

                    % if isempty(record_pos_reward)
                    %     pos_reward = [];
                    % else
                    %     pos_reward = record_pos_reward(1);
                    % end
    
                    if isempty(pos_reward)
                        reward_type = -1;
                    elseif pos_reward < sub_bound(1)
                        reward_type = 1;
                    elseif sub_bound(1) <= pos_reward && pos_reward <= sub_bound(2)
                        reward_type = 0;
                    else
                        reward_type = -1;
                    end
    
                    start_id = round(start_pos / params.space_unit);
                    left = start_id - params.len_before_lick;
                    right = start_id + params.len_after_lick;
                    % left = round(sub_bound(1) / params.space_unit);
                    % right = round(sub_bound(2) / params.space_unit);
                    sub_fr_trials(:,id_trial,:) = fr(:,id_trial,left:right);
    
                    lick_type_trials(id_trial) = lick_type;
                    reward_type_trials(id_trial) = reward_type;
    
                end

                lick_codes = [1, 0];
                reward_codes = [-1, 0, 1];
    
                for Lidx = 1:params.num_lick_type
                    for Widx = 1:params.num_reward_type
                        mask = (lick_type_trials == lick_codes(Lidx)) & ...
                               (reward_type_trials == reward_codes(Widx));

                        if any(mask)
                            sub = sub_fr_trials(:, mask, :);    % [N × T_sel × W]
                            mean_fr = squeeze(mean(sub, 2));      % [N × W]
                        else
                            mean_fr = [];
                        end

                        processed_fr{r, c, id_sub, Lidx, Widx} = mean_fr;
                    end
                end
    
            end
    
            % average & clip & collect
            fr = mean(fr,2);
            fr = squeeze(fr);
            fr = fr(:,params.left_track_idx:params.right_track_idx);
            blocks{end+1} = fr;

        end
    end

    fr_sum = [blocks{:}];

    mu  = mean(fr_sum, 2);
    sg  = std(fr_sum, 0, 2);
    sg  = max(sg, eps);

    mask = ~cellfun('isempty', processed_fr);
    processed_fr(mask) = cellfun(@(x) (x - mu) ./ sg, processed_fr(mask), ...
                                 'UniformOutput', false);

    %% extract the data to analyze

    rows = cellfun(@(f) params.(f), params.ana_tt);
    cols = cellfun(@(f) params.(f), params.ana_bt);

    [R, C, S, L, W] = ndgrid(rows, cols, 1:params.num_sub_type, ...
                        1:params.num_lick_type,1:params.num_reward_type);

    combinations = [R(:), C(:), S(:), L(:), W(:)];

    ana_fr = cell(numel(params.tt), numel(params.bt), ...
                    params.num_sub_type, params.num_lick_type,params.num_reward_type);
    blocks = {};

    for i = 1:size(combinations, 1)
        r = combinations(i, 1);
        c = combinations(i, 2);
        s = combinations(i, 3);
        l = combinations(i, 4);
        w = combinations(i, 5);
        
        fr = processed_fr{r, c, s, l, w};
        if isempty(fr), continue; end
        
        ana_fr{r, c, s, l, w} = fr;
        blocks{end+1} = fr;
    end

    ana_fr_sum = [blocks{:}];
    cord.ana_fr = ana_fr;
    cord.ana_fr_sum = fr_sum;

end

