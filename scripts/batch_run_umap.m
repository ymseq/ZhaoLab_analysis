%%
clc;
clear;
addpath(genpath('./src'));
set(0, 'DefaultFigureVisible', 'on');


%%
params = setParams();
params.ana_tt = {'origin','pattern_1','pattern_2','pattern_3', ...
                 'position_1','position_2','position_3'};
params.ana_bt = {'correct'};
export_json_filename = 'correct_all_rules.json';

run_Track(params, export_json_filename);

%%
function run_Track(params, export_json_filename)

    task_types = {'first_to_pat','first_to_pos', ...
                'flexible_shift','second_shift'};

    for i = 1:numel(task_types)
        
        params.task_type = task_types{i};

        cords = loadData(params);
        
        for j = 1:numel(cords)
            try
                cord = cords{j};
                cord = alignTrack(cord, params);
                exportUmap(cord, params, export_json_filename);
            catch ME
                fprintf('Failed to run %s\n', cord.mice);
                fprintf('Error message: %s\n', ME.message);
                fprintf('Error stack: %s\n', ME.stack(1).file);
            end
        end

    end

end