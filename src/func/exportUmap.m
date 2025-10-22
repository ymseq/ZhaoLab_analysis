function exportUmap(cord, params, file_name)


    rows = cellfun(@(f) params.(f), params.ana_tt);
    cols = cellfun(@(f) params.(f), params.ana_bt);

    json_data = struct();

    for r = rows
        for c = cols

            fr = cord.ana_fr{r, c};
            if isempty(fr), continue; end

            field_name = [params.tt{r} '_' params.bt{c}];
            json_data.(field_name) = fr;

        end
    end

    out_path = fullfile(params.save_path, 'json_temp', 'umap', params.task_type, cord.mice, 'alignTrack', file_name);

    % Ensure directory exists
    fdir = fileparts(out_path);
    if ~exist(fdir, 'dir')
        mkdir(fdir);
    end

    % Write JSON
    jsonStr = jsonencode(json_data);
    fid = fopen(out_path, 'w');
    fwrite(fid, jsonStr, 'char');
    fclose(fid);

end

