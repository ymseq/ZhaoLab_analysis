function plot3D_2(x_lines, y_lines, z_lines, lineColors, lineLabels, params)

    num_lines = numel(x_lines);
    marker = 'o';
    markerCount = 25;
    markerSize  = 36;
    
    h = figure('Color','w'); hold on; grid on; box on;
    h.Position = [200 200 1200 600];
    ax = gca; ax.FontSize = 16;
    xlabel('PC1'); ylabel('PC2'); zlabel('PC3'); view(35,25);
    
    uniqueLabels = {};
    legendHandles = [];

    for idx = 1:num_lines

        xi = x_lines{idx}; yi = y_lines{idx}; zi = z_lines{idx};
        T = numel(xi);
        mkIdx = unique(round(linspace(1, T, min(T, markerCount))));

        color = lineColors{idx};

        h = plot3(xi, yi, zi, ...
            '-', 'Color', color, 'LineWidth', 1.5);

        scatter3(xi(mkIdx), yi(mkIdx), zi(mkIdx), markerSize, ...
            'Marker', marker, 'MarkerEdgeColor', color, ...
            'MarkerFaceColor', 'w', 'LineWidth', 1.0);

        scatter3(xi(1), yi(1), zi(1), markerSize, ...
            'Marker', marker, 'MarkerEdgeColor', 'red', ...
            'MarkerFaceColor', 'red');
        scatter3(xi(end), yi(end), zi(end), markerSize, ...
            'Marker', marker, 'MarkerEdgeColor', 'black', ...
            'MarkerFaceColor', 'black');

        if ~ismember(lineLabels{idx}, uniqueLabels)
            uniqueLabels{end+1} = lineLabels{idx};
            legendHandles(end+1) = h;
        end

    end

    legend(legendHandles, uniqueLabels, 'Interpreter','none', 'FontSize', 8);

end

