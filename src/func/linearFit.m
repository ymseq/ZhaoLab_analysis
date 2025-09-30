function cord = linearFit(cord, params)

    % reconstruct the matrix
    % fr: N_units * (N_times *N_conditions)
    fr = cord.units_fr_sum;
    % fr: N_units * (N_times / 5) * (5 * N_conditions)
    fr = reshape(fr,size(fr,1),params.len_sub_trial, []);

    len_r = numel(cord.trial_types);
    len_c = numel(cord.behavior_types);

    % var_matrix: (5 * N_conditions) * 3 var
    % position (1 to 5), choice (1 or -1), cross fig (1 or -1)
    var_matrix = zeros(size(fr,3),3);
    sum_idx = 0;
    for row = 1:len_r
        for col = 1:len_c
            if isempty(cord.processed_fr{row,col})
                continue;
            end
            trial_type = cord.trial_types{row};
            behavior_type = cord.behavior_types{col};

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

