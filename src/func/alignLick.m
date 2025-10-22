function cord = alignLick(cord, params)

    %% preprocess whole data

    rows = cellfun(@(f) params.(f), params.tt);
    cols = cellfun(@(f) params.(f), params.bt);

    processed_fr = cell(numel(params.tt), numel(params.bt), ...
                    params.num_sub_type, params.num_lick_type);

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

                sub_fr_trials = zeros(cord.num_neurons, size(fr,2), params.len_lick);
                is_lick_trials = zeros(1,size(fr,2));

                for id_trial = 1:size(fr,2)

                    start_pos = sub_bound(1) + params.len_before_lick * params.space_unit;
                    is_lick = 0;

                    if isa(pos_lick_trials, 'cell')
                        pos_lick = pos_lick_trials{id_trial};
                    elseif isempty(pos_lick_trials)
                        pos_lick = [];
                    elseif isa(pos_lick_trials, 'double') && size(fr,2)==1
                        pos_lick = squeeze(pos_lick_trials);
                    else
                        error('Unkown structure of pos_lick_type');
                    end

                    for i = 1:numel(pos_lick)
                        if sub_bound(1) <= pos_lick(i) && pos_lick(i) <= sub_bound(2)
                            start_pos = pos_lick(i);
                            is_lick = 1;
                            break;
                        end
                    end

                    start_id = round(start_pos / params.space_unit);
                    left = start_id - params.len_before_lick;
                    right = start_id + params.len_after_lick;
                    sub_fr_trials(:,id_trial,:) = fr(:,id_trial,left:right);

                    is_lick_trials(id_trial) = is_lick;

                end

                mask_lick = is_lick_trials == 1;
                mask_nonlick = is_lick_trials == 0;
                sub_fr_lick = sub_fr_trials(:, mask_lick, :);
                sub_fr_nonlick = sub_fr_trials(:, mask_nonlick, :);

                if ~isempty(sub_fr_lick)
                    mean_fr_lick = squeeze(mean(sub_fr_lick, 2));
                    % blocks{end+1} = mean_fr_lick;
                else
                    mean_fr_lick = [];
                end
                if ~isempty(sub_fr_nonlick)
                    mean_fr_nonlick = squeeze(mean(sub_fr_nonlick, 2));
                    % blocks{end+1} = mean_fr_nonlick;
                else
                    mean_fr_nonlick = [];
                end

                processed_fr{r,c,id_sub,1} = mean_fr_lick;
                processed_fr{r,c,id_sub,2} = mean_fr_nonlick;

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

    [R, C, S, L] = ndgrid(rows, cols, 1:params.num_sub_type, 1:params.num_lick_type);
    combinations = [R(:), C(:), S(:), L(:)];

    ana_fr = cell(numel(params.tt), numel(params.bt), params.num_sub_type, params.num_lick_type);
    blocks = {};

    for i = 1:size(combinations, 1)
        r = combinations(i, 1);
        c = combinations(i, 2);
        s = combinations(i, 3);
        l = combinations(i, 4);
        
        fr = processed_fr{r, c, s, l};
        if isempty(fr), continue; end
        
        ana_fr{r, c, s, l} = fr;
        blocks{end+1} = fr;
    end

    ana_fr_sum = [blocks{:}];
    cord.ana_fr = ana_fr;
    cord.ana_fr_sum = ana_fr_sum;

end

