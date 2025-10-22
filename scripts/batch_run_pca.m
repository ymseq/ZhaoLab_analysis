%%
clc;
clear;
addpath(genpath('./src'));
set(0, 'DefaultFigureVisible', 'on');

%%
params = setParams();
params.ana_tt = {'origin','pattern_1','pattern_2','pattern_3', ...
                 'position_1','position_2','position_3'};
params.ana_bt = {'correct','miss'};
export_json_filename = 'correct_miss_all_rules.json';
task_types = {'second_shift'};

run_Track(params, export_json_filename, task_types);
run_Lick(params, export_json_filename, task_types);


%%
params = setParams();
params.ana_tt = {'origin','pattern_1','pattern_2','pattern_3', ...
                 'position_1','position_2','position_3'};
params.ana_bt = {'correct'};
export_json_filename = 'correct_all_rules.json';
task_types = {'first_to_pat','first_to_pos', ...
                'flexible_shift','second_shift'};

run_Track(params, export_json_filename, task_types);
run_Lick(params, export_json_filename, task_types);


%%
params.ana_bt = {'correct','false'};
export_json_filename = 'correct_false_all_rules.json';

run_Track(params, export_json_filename, task_types);
run_Lick(params, export_json_filename, task_types);


%%
params.ana_bt = {'false'};
export_json_filename = 'false_all_rules.json';

run_Track(params, export_json_filename, task_types);
run_Lick(params, export_json_filename, task_types);



%%
function run_Track(params, export_json_filename,task_types)

    for i = 1:numel(task_types)
        
        params.task_type = task_types{i};

        cords = loadData(params);
        
        for j = 1:numel(cords)
            try
                runTrack(cords{j}, params, export_json_filename, 0);
            catch ME
                fprintf('Failed to run %s\n', cords{j}.mice);
                fprintf('Error message: %s\n', ME.message);
                fprintf('Error stack: %s\n', ME.stack(1).file);
            end
        end

    end

end


function run_Lick(params, export_json_filename, task_types)

    for i = 1:numel(task_types)
        
        params.task_type = task_types{i};

        cords = loadData(params);
        
        for j = 1:numel(cords)
            try
                runLick(cords{j}, params, export_json_filename, 0);
            catch ME
                fprintf('Failed to run %s\n', cords{j}.mice);
                fprintf('Error message: %s\n', ME.message);
                fprintf('Error stack: %s\n', ME.stack(1).file);
            end
        end

    end

end
