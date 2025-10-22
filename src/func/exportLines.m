function exportLines(x_lines, y_lines, z_lines, lineColors, lineLabels, out_path)
% EXPORTLINES Save multiple 3D trajectories with color/label info to a JSON file.
% 
% Parameters:
%   x_lines     - 1xN cell array; each cell is a 1xT or Tx1 numeric vector for X
%   y_lines     - 1xN cell array; each cell is a 1xT or Tx1 numeric vector for Y
%   z_lines     - 1xN cell array; each cell is a 1xT or Tx1 numeric vector for Z
%   lineColors  - 1xN cell array (optional); per-line color, each element can be:
%                   (a) 1x3 numeric RGB vector in [0,1]
%                   (b) '#RRGGBB' string
%   lineLabels  - 1xN cell array (optional); per-line label (char or string)
%   out_path    - target JSON path, e.g., 'results/json_temp/sessionA/run01/lines.json'
%
% Notes:
%   - Colors given as numeric RGB will be clamped into [0,1] and stored as a numeric triplet.
%     The Python consumer can convert them to hex if needed.

    N = numel(x_lines);
    lines = cell(1, N);

    for i = 1:N
        xi = x_lines{i}(:)'; 
        yi = y_lines{i}(:)'; 
        zi = z_lines{i}(:)';

        assert(numel(xi) == numel(yi) && numel(yi) == numel(zi), ...
            'Line %d has mismatched x/y/z lengths.', i);

        item = struct();
        item.x = xi; 
        item.y = yi; 
        item.z = zi;

        % Color: prefer numeric RGB [0..1], alternatively '#RRGGBB' string.
        ci = [];
        if ~isempty(lineColors) && ~isempty(lineColors{i})
            c = lineColors{i};
            if isnumeric(c) && numel(c) == 3
                c = max(0, min(1, c(:)')); % clamp to [0,1]
                ci = c;
            elseif (ischar(c) && numel(c) == 7 && c(1) == '#') || ...
                   (isstring(c) && isscalar(c) && strlength(c) == 7 && startsWith(c, "#"))
                ci = char(c);
            else
                error('Unrecognized color format for line %d', i);
            end
        end
        if ~isempty(ci)
            item.color = ci; % numeric triplet or '#RRGGBB'
        end

        % Label: use provided label or fallback
        li = [];
        if ~isempty(lineLabels) && ~isempty(lineLabels{i})
            li = char(lineLabels{i});
        else
            error('Label for line %d is empty!', i);
        end
        item.label = li;

        lines{i} = item;
    end

    data = struct('lines', {lines});

    % Ensure directory exists
    fdir = fileparts(out_path);
    if ~exist(fdir, 'dir')
        mkdir(fdir);
    end

    % Write JSON
    jsonStr = jsonencode(data);
    fid = fopen(out_path, 'w');
    fwrite(fid, jsonStr, 'char');
    fclose(fid);

end
