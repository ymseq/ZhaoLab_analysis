function cord = pcaFit(cord, params)

    X = permute(cord.ana_fr_sum,[2,1]);
    [coeff, ~, ~] = pca(X);
    pcs = coeff(:, 1:params.num_pca);

    denoise_matrix = zeros(cord.num_neurons, cord.num_neurons);
    for a = 1:params.num_pca
        denoise_matrix = denoise_matrix + pcs(:, a) * pcs(:, a)';
    end

    cord.ana_fr_sum = denoise_matrix * cord.ana_fr_sum;

    cord.denoise_matrix = denoise_matrix;
    cord.pcs = pcs;
    
end

