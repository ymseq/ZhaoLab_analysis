function runTrack(cord, params, file_name, color_choice)

    cord = alignTrack(cord, params);
    cord = pcaFit(cord, params);
    
    vecs = cord.pcs(:,1:3);
    x_vec = reshape(vecs(:,1),1,[]);
    y_vec = reshape(vecs(:,2),1,[]);
    z_vec = reshape(vecs(:,3),1,[]);

    len_r = numel(params.ana_tt);
    len_c = numel(params.ana_bt);
    
    jet_colors = jet(len_r * len_c);
    jet_colors = reshape(jet_colors, len_r, len_c, 3);

    rule_colors = [ ...
        0.20 0.20 0.20
        0.99 0.22 0.24;
        0.99 0.55 0.16;
        0.80 0.12 0.46;
        0.20 0.45 0.85;
        0.00 0.62 0.45;
        0.53 0.36 0.78];
    
    lineColors = {};
    lineLabels = {};
    xlines = {};
    ylines = {};
    zlines = {};
    
    for id1 = 1:numel(params.ana_tt)
        for id2 = 1:numel(params.ana_bt)
            row = params.(params.ana_tt{id1});
            col = params.(params.ana_bt{id2});
            if isempty(cord.ana_fr{row,col})
                continue;
            end
    
            fr = cord.ana_fr{row,col};
            
            xline = x_vec * fr;
            yline = y_vec * fr;
            zline = z_vec * fr;
    
            xline = reshape(xline, [], params.len_track);
            yline = reshape(yline, [], params.len_track);
            zline = reshape(zline, [], params.len_track);
    
            xlines{end+1} = xline;
            ylines{end+1} = yline;
            zlines{end+1} = zline;
    
            label = [params.ana_tt{id1} ' ' params.ana_bt{id2}];
            lineLabels{end+1} = label;
    
            if color_choice == 0
                color = rule_colors(row,:);
            else 
                color = jet_colors(id1, id2, :);
            end
            lineColors{end+1} = color;
            
        end
    end
    
    out_path = fullfile(params.save_path, 'json_temp', 'pca', params.task_type, cord.mice, 'alignTrack', file_name);

    exportLines(xlines,ylines,zlines,lineColors,lineLabels,out_path);


end

