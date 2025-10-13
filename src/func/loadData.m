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
        cord.behavior_types = {'correct', 'false', 'miss'};

        for id1 = 1:numel(params.ana_tt)
            for id2 = 1:numel(params.ana_bt)
                row = params.(params.ana_tt{id1});
                col = params.(params.ana_bt{id2});
                if ~isempty(cord.simple_firing{row, col})
                    cord.num_neurons = size(cord.simple_firing{row, col},2);
                end
            end
        end

        if cord.num_neurons == 0
            error('Analyzed data could not be empty!');
        end

        cords{idx} = cord;

    end

end

