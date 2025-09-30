function cords = loadData(params)

    files = dir(fullfile(params.data_path,'*.mat'));

    num_files = numel(files);
    cords = cell(num_files,1);

    for idx = 1:num_files
        
        data_file = fullfile(params.data_path,files(idx).name);
        load(data_file, 'zones', 'simple_type', 'simple_firing');

        cord.zones = zones;
        cord.simple_firing = simple_firing;
        trial_types = cell(size(simple_type,1),1);
        for i = 1:numel(trial_types)
            trial_types{i} = strtrim(simple_type(i,:));
        end
        cord.trial_types = trial_types;
        cord.behavior_types = {'correct'};

        for row = numel(cord.trial_types)
            for col = numel(cord.behavior_types)
                if ~isempty(cord.simple_firing{row, col})
                    cord.num_neurons = size(cord.simple_firing{row, col},2);
                end
            end
        end

        cords{idx} = cord;

    end

end

