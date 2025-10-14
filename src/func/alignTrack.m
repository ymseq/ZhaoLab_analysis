function cord = alignTrack(cord,params)

    %% preprocess whole data

    rows = cellfun(@(f) params.(f), params.tt);
    cols = cellfun(@(f) params.(f), params.bt);

    processed_fr = cell(numel(params.tt), numel(params.bt));

    g1d = fspecial('gaussian', [1 params.gaussian_range], params.gaussian_sigma);
    g2d = reshape(g1d, 1, []);  % 1 x K

    blocks = {};

    for r = rows
        for c = cols
            fr = cord.simple_firing{r, c};
            if isempty(fr), continue; end
    
            % [N x len_all]
            fr = mean(fr,3);
            fr = squeeze(fr);

            % gaussian smooth
            fr = convn(fr, g2d, 'same');
    
            % clip, [N x len_trial]        
            fr = fr(:, params.left_track_idx : params.right_track_idx);
    
            processed_fr{r,c} = fr;
    
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

    ana_fr = cell(numel(params.tt), numel(params.bt));

    blocks = {};

    for r = rows
        for c = cols
            fr = processed_fr{r, c};
            if isempty(fr), continue; end
            ana_fr{r,c} = fr;
            blocks{end+1} = fr;
        end
    end

    ana_fr_sum = [blocks{:}];

    cord.ana_fr = ana_fr;
    cord.ana_fr_sum = ana_fr_sum;

end

