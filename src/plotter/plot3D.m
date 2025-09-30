function plot3D(vecs, tnames, bname, cord, params, option)

    switch option
        case 1
            plot3D_1(vecs, tnames, bname, cord, params);
        case 2
            plot3D_2(vecs, tnames, bname, cord, params);

    end

end



function plot3D_1(vecs, tnames, bname, cord, params)

    num_trial_type = numel(tnames);
    
    x_lines = zeros(num_trial_type, params.len_trial);
    y_lines = zeros(num_trial_type, params.len_trial);
    z_lines = zeros(num_trial_type, params.len_trial);

    x_vec = reshape(vecs(:,1),1,[]);
    y_vec = reshape(vecs(:,2),1,[]);
    z_vec = reshape(vecs(:,3),1,[]);

    for idx = 1:num_trial_type
        tname = tnames{idx};
        fr = cord.processed_fr{params.(tname),params.(bname)};
        x_lines(idx,:) = x_vec * fr;
        y_lines(idx,:) = y_vec * fr;
        z_lines(idx,:) = z_vec * fr;
    end

    T = size(x_lines, 2);

    str_names = string(tnames);
    patIds = find(startsWith(str_names, "pattern"));
    posIds = find(startsWith(str_names, "position"));

    groupIdx = {};
    if ~isempty(patIds), groupIdx{end+1} = patIds; end
    if ~isempty(posIds), groupIdx{end+1} = posIds; end

    warmPalette = [ ...
        0.99 0.22 0.24;
        0.99 0.55 0.16;
        0.80 0.12 0.46];

    coolPalette = [ ...
        0.20 0.45 0.85;
        0.00 0.62 0.45;
        0.53 0.36 0.78];

    markerStyles = {'o','s','^'};
    markerCount = 25;
    markerSize  = 36;
    
    h = figure('Color','w'); hold on; grid on; box on;
    h.Position = [200 200 1200 600];
    ax = gca; ax.FontSize = 16;
    xlabel('X'); ylabel('Y'); zlabel('Z'); view(35,25);
    
    legendLines   = gobjects(1,num_trial_type);

    for g = 1:numel(groupIdx)

        ids   = groupIdx{g};

        for k = 1:numel(ids)

            i  = ids(k);
            xi = x_lines(i,:); yi = y_lines(i,:); zi = z_lines(i,:);
            mkIdx = unique(round(linspace(1, T, min(T, markerCount))));

            style_idx = str2double(regexp(tnames{i}, '(\d+)$', 'tokens', 'once'));

            if ~isempty(patIds) && any(i==patIds)    % pattern 组
                color = warmPalette(style_idx, :);
            else                                     % position 组
                color = coolPalette(style_idx, :);
            end
            marker = markerStyles{style_idx};

            h = plot3(xi, yi, zi, ...
                '-', 'Color', color, 'LineWidth', 1.5);
            legendLines(i) = h;
    
            scatter3(xi(mkIdx), yi(mkIdx), zi(mkIdx), markerSize, ...
                'Marker', marker, 'MarkerEdgeColor', color, ...
                'MarkerFaceColor', 'w', 'LineWidth', 1.0);

            scatter3(xi(1), yi(1), zi(1), markerSize, ...
                'Marker', marker, 'MarkerEdgeColor', 'red', ...
                'MarkerFaceColor', 'red');
            scatter3(xi(end), yi(end), zi(end), markerSize, ...
                'Marker', marker, 'MarkerEdgeColor', 'black', ...
                'MarkerFaceColor', 'black');

        end
    end

    legend(legendLines, tnames, 'Interpreter','none');

end


function plot3D_2(vecs, tnames, bname, cord, params)

    num_trial_type = numel(tnames);
    
    x_lines = zeros(num_trial_type, params.len_trial);
    y_lines = zeros(num_trial_type, params.len_trial);
    z_lines = zeros(num_trial_type, params.len_trial);

    x_vec = reshape(vecs(:,1),1,numel(vecs(:,1)));
    y_vec = reshape(vecs(:,2),1,numel(vecs(:,2)));
    z_vec = reshape(vecs(:,3),1,numel(vecs(:,3)));

    timeColors = [
        0.27  0.00  0.33;
        0.23  0.32  0.55;
        0.13  0.57  0.55;
        0.37  0.79  0.38;
        0.99  0.91  0.15;
    ];
    segments = 5;

    for idx = 1:num_trial_type
        tname = tnames{idx};
        fr = cord.processed_fr{params.(tname),params.(bname)};
        x_lines(idx,:) = x_vec * fr;
        y_lines(idx,:) = y_vec * fr;
        z_lines(idx,:) = z_vec * fr;
    end

    T = size(x_lines, 2);

    str_names = string(tnames);
    patIds = find(startsWith(str_names, "pattern"));
    posIds = find(startsWith(str_names, "position"));

    groupIdx = {};
    if ~isempty(patIds), groupIdx{end+1} = patIds; end
    if ~isempty(posIds), groupIdx{end+1} = posIds; end

    markerStyles = {'o','s','^','d','v','>'};
    markerCount = 25;
    markerSize  = 40;

    h = figure('Color','w'); hold on; grid on; box on;
    h.Position = [200 200 1200 600];
    ax = gca; ax.FontSize = 16;
    xlabel('X'); ylabel('Y'); zlabel('Z'); view(35,25);

    legendMarkers   = gobjects(1,num_trial_type);
    legendLines = gobjects(1,num_trial_type);

    for g = 1:numel(groupIdx)

        ids   = groupIdx{g};

        for k = 1:numel(ids)

            i  = ids(k);
            xi = x_lines(i,:); yi = y_lines(i,:); zi = z_lines(i,:);
            mkIdx = unique(round(linspace(1, T, min(T, markerCount))));

            style_idx = str2double(regexp(tnames{i}, '(\d+)$', 'tokens', 'once'));

            if ~isempty(patIds) && any(i==patIds)    % pattern 组
                marker = markerStyles{style_idx};
            else                                     % position 组
                marker = markerStyles{style_idx+3};
            end

            for seg = 1:segments
                l = (seg - 1) * params.len_sub_trial + 1;
                r = (seg) * params.len_sub_trial + 1;
                r = min(r,params.len_trial);
                plot3(xi(l:r), yi(l:r), zi(l:r), ...
                    '-', 'Color', timeColors(seg, :), 'LineWidth', 1.5);
            end
    
            s = scatter3(xi(mkIdx), yi(mkIdx), zi(mkIdx), markerSize, ...
                'Marker', marker, 'MarkerEdgeColor', 'blue', ...
                'MarkerFaceColor', 'w', 'LineWidth', 1.0);
            legendMarkers(i) = s;

            scatter3(xi(1), yi(1), zi(1), markerSize, ...
                'Marker', marker, 'MarkerEdgeColor', 'red', ...
                'MarkerFaceColor', 'red');
            scatter3(xi(end), yi(end), zi(end), markerSize, ...
                'Marker', marker, 'MarkerEdgeColor', 'black', ...
                'MarkerFaceColor', 'black');

        end
    end

    legend(legendMarkers, tnames, 'Interpreter','none');

end
