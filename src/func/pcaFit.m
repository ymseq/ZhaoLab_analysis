function cord = pcaFit(cord, params)

    X = permute(cord.units_fr_sum,[2,1]);
    [coeff, ~, ~] = pca(X);
    pcs = coeff(:, 1:params.num_pca);

    denoise_matrix = zeros(cord.num_neurons, cord.num_neurons);
    for a = 1:params.num_pca
        denoise_matrix = denoise_matrix + pcs(:, a) * pcs(:, a)';
    end

    cord.units_fr_sum = denoise_matrix * cord.units_fr_sum;

    len_r = numel(cord.trial_types);
    len_c = numel(cord.behavior_types);
    for row = 1:len_r
        for col = 1:len_c
            if isempty(cord.processed_fr{row,col})
                continue;
            end

            cord.processed_fr{row,col} = denoise_matrix * cord.processed_fr{row,col};

        end
    end

    cord.denoise_matrix = denoise_matrix;
    cord.pcs = pcs;
    
end

