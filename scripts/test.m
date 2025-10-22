% --- 创建交互式 3D 散点图 ---
f = uifigure('Name', '3D Scatter HTML Export');
ax = uiaxes(f);
scatter3(ax, rand(100,1), rand(100,1), rand(100,1), 50, 'filled');
xlabel(ax, 'X'); ylabel(ax, 'Y'); zlabel(ax, 'Z');
title(ax, 'Interactive 3D Scatter (Export Demo)');
rotate3d(ax, 'on');

% --- 获取 Web 渲染的 HTML 内容 ---
drawnow;  % 确保渲染完成
htmlSource = f.HTMLSource;   % undocumented 属性

% --- 导出到 HTML 文件 ---
fid = fopen('scatter3_interactive.html','w');
fprintf(fid, '%s', htmlSource);
fclose(fid);

disp('✅ 导出成功：scatter3_interactive.html（可用浏览器直接打开）');
