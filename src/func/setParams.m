function params = setParams()

params.version = 'v1';

params.data_path = fullfile(pwd,'data/');

% The idx in data of different group
params.origin = 1;
params.pattern_1 = 2;
params.pattern_2 = 3;
params.pattern_3 = 4;
params.position_1 = 5;
params.position_2 = 6;
params.position_3 = 7;

params.correct = 1;
params.false = 2;
params.miss = 3;

% one point of data repersent 0.1 cm in real world
params.space_unit = 0.1;
params.len_sub_trial = 600;
params.len_trial = 3000;
% discard the beginning & end of the trial
params.left_boundary_idx = 101;
params.right_boundary_idx = 3100;
% the choosen length when align data by lick postion
params.len_before_lick = 8 * 10;
params.len_after_lick = 4 * 10;

% the parameter for gaussiam smooth
params.gaussian_sigma = 10;

params.num_pca = 12;

params.save_path = fullfile(pwd,'results/');

params.ana_tt = {'pattern_1','pattern_2','pattern_3', ...
                 'position_1','position_2','position_3'};
params.ana_bt = {'false'};

end

