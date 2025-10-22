function params = setParams()

    params.version = 'v2';
    
    params.data_path = fullfile(pwd,'data/');
    
    % The idx in data of different group

    params.tt = {'origin','pattern_1','pattern_2','pattern_3', ...
                     'position_1','position_2','position_3'};
    params.bt = {'correct', 'false', 'miss'};

    params.task_type = 'flexible_shift';

    for i = 1:numel(params.tt)
        params.(params.tt{i}) = i;
    end
    
    for i = 1:numel(params.bt)
        params.(params.bt{i}) = i;
    end
    
    % one point of data repersent 0.1 cm in real world
    params.space_unit = 0.1;
    % discard the beginning & end of the trial
    params.left_track_idx = 101;
    params.right_track_idx = 3100;
    params.len_track = params.right_track_idx - params.left_track_idx + 1;
    % the choosen length when align data by lick postion
    params.len_before_lick = 1 * 10;
    params.len_after_lick = 1 * 10;
    params.len_lick = params.len_before_lick + params.len_after_lick + 1;
    
    % the parameter for gaussiam smooth
    params.gaussian_range = 10;
    params.gaussian_sigma = 10;
    
    params.num_pca = 20;
    
    params.save_path = fullfile(pwd,'results/');
    
    params.num_sub_type = 5;
    params.num_lick_type = 2;
    params.num_reward_type = 3;
    
    params.ana_tt = {'pattern_1','pattern_2','pattern_3', ...
                     'position_1','position_2','position_3'};
    params.ana_bt = {'correct'};

end

