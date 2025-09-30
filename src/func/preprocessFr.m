function cord = preprocessFr(cord, params)

    len_r = numel(cord.trial_types);
    len_c = numel(cord.behavior_types);

    processed_fr = cell(len_r, len_c);

    num_units_fr_sum = 0;

    for row = 1:len_r
        for col = 1:len_c
            
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
    for row = 1:len_r
        for col = 1:len_c
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

    for row = 1:len_r
        for col = 1:len_c
            if isempty(processed_fr{row,col})
                continue;
            end
            processed_fr{row,col} = (processed_fr{row,col} - mean_units) ./ std_units;
        end
    end

    cord.processed_fr = processed_fr;
    cord.units_fr_sum = units_fr_sum;
    
end

