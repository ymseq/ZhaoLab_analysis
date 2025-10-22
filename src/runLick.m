function runLick(cord, params, file_name, color_choice)

    temp_ana_tt = params.ana_tt;
    temp_ana_bt = params.ana_bt;

    % Default analysis part of PCA
    params.ana_tt = {'origin','pattern_1','pattern_2','pattern_3', ...
                     'position_1','position_2','position_3'};
    params.ana_bt = {'correct'};

    cord = alignTrack(cord, params);
    cord = pcaFit(cord, params);
    
    vecs = cord.pcs(:,1:3);
    x_vec = reshape(vecs(:,1),1,[]);
    y_vec = reshape(vecs(:,2),1,[]);
    z_vec = reshape(vecs(:,3),1,[]);
    
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
    
            label = [params.ana_tt{id1} '_' params.ana_bt{id2}];
            lineLabels{end+1} = label;
    
            lineColors{end+1} = [0.7, 0.7, 0.7];
            
        end
    end
    
    % Return to previous setting
    params.ana_tt = temp_ana_tt;
    params.ana_bt = temp_ana_bt;
    
    cord = alignLick(cord, params);
    cord = pcaFit(cord, params);
    
    len_r = numel(params.ana_tt);
    len_c = numel(params.ana_bt);
    len_s = params.num_sub_type;
    len_l = params.num_lick_type;
    
    [C, R, S, L] = ndgrid(1:len_r, 1:len_c, 1:len_s, 1:len_l);
    combinations = [C(:), R(:), S(:), L(:)];
    num_combinations = size(combinations, 1);
    
    jet_colors = jet(num_combinations);
    jet_colors = reshape(jet_colors,len_r,len_c,len_s,len_l,[]);
    position_colors = jet(5);
    
    for i = 1:num_combinations
    
        id1 = combinations(i, 1);
        id2 = combinations(i, 2);
        s = combinations(i, 3);
        l = combinations(i, 4);
    
        row = params.(params.ana_tt{id1});
        col = params.(params.ana_bt{id2});
        
        if isempty(cord.ana_fr{row, col, s, l})
            continue;
        end
        fr = cord.ana_fr{row, col, s, l};
        
        xline = x_vec * fr;
        yline = y_vec * fr;
        zline = z_vec * fr;
        xline = reshape(xline, [], params.len_lick);
        yline = reshape(yline, [], params.len_lick);
        zline = reshape(zline, [], params.len_lick);
        
        xlines{end+1} = xline;
        ylines{end+1} = yline;
        zlines{end+1} = zline;
        
        label = sprintf('%s %s sub%d lick%d', ...
            params.ana_tt{id1}, params.ana_bt{id2}, s, l);
        lineLabels{end+1} = label;
        
        % color = colors(id1,id2,s,l,:);
        if color_choice == 0
            color = position_colors(s,:);
        else
            color = jet_colors(id1,id2,s,l,:);
        end

        lineColors{end+1} = color;
    end

    out_path = fullfile(params.save_path, 'json_temp', 'pca', params.task_type, cord.mice, 'alignLick', file_name);

    exportLines(xlines,ylines,zlines,lineColors,lineLabels,out_path);

end

