function params = setParams()

params.version = 'v1';

params.data_path = fullfile(pwd,'data/');

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

params.space_unit = 0.1;
params.len_sub_trial = 600;
params.left_boundary_idx = 101;
params.right_boundary_idx = 3100;
params.len_trial = 3000;

params.gaussian_sigma = 10;

params.num_pca = 12;

params.save_path = fullfile(pwd,'results/');

end

