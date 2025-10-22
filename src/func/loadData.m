function cords = loadData(params)

    task_data_path = fullfile(params.data_path, params.task_type);

    files = dir(fullfile(task_data_path,'*.mat'));

    num_files = numel(files);
    cords = cell(num_files,1);

    for idx = 1:num_files
        
        data_file = fullfile(task_data_path,files(idx).name);
        load(data_file, 'zones', 'simple_firing', 'pos_lick_type','pos_reward_type');

        cord.zones = zones;
        cord.simple_firing = simple_firing;
        cord.pos_lick_type = pos_lick_type;
        cord.pos_reward_type = pos_reward_type;
        [~, file_name] = fileparts(files(idx).name);
        cord.mice = file_name;

        cord.num_neurons = 0 ;
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

