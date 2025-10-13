function cord = preprocessFr(cord, params)

    len_r = numel(params.ana_tt);
    len_c = numel(params.ana_bt);

    processed_fr = cell(numel(cord.trial_types), numel(cord.behavior_types));

    num_units_fr_sum = 0;

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
            kernel = fspecial('gaussian', [1, 11], params.gaussian_sigma);
            for i = 1:size(fr,1)
                fr(i, :) = conv(fr(i, :), kernel, 'same');
            end

            % clip
            fr = fr(:,params.left_boundary_idx:params.right_boundary_idx);

            processed_fr{row,col} = fr;

            % cal whole fr of units
            num_units_fr_sum = num_units_fr_sum + size(fr,2);
        end
    end

    units_fr_sum = zeros(cord.num_neurons, num_units_fr_sum);

    sum_idx = 0;
    for id1 = 1:len_r
        for id2 = 1:len_c
            row = params.(params.ana_tt{id1});
            col = params.(params.ana_bt{id2});
            if isempty(processed_fr{row,col})
                continue;
            end

            fr = processed_fr{row,col};
            plus = params.len_trial;
            units_fr_sum(:,(sum_idx + 1):(sum_idx + plus)) = fr;
            sum_idx = sum_idx + plus;

        end
    end

    mean_units = mean(units_fr_sum, 2);
    std_units = std(units_fr_sum, 0, 2);

    units_fr_sum = (units_fr_sum - mean_units) ./ std_units;

    for id1 = 1:len_r
        for id2 = 1:len_c
            row = params.(params.ana_tt{id1});
            col = params.(params.ana_bt{id2});
            if isempty(processed_fr{row,col})
                continue;
            end
            processed_fr{row,col} = (processed_fr{row,col} - mean_units) ./ std_units;
        end
    end

    cord.processed_fr = processed_fr;
    cord.units_fr_sum = units_fr_sum;
    
end

