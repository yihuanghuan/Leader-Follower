%% plot_single.m - 双重维度修复版 (兼容所有情况)
clear p_data pr_data t_data;

% --- 1. 读取数据 ---
if exist('out_p', 'var')
    p_raw = out_p.Data;
    t_raw = out_p.Time;
elseif exist('out', 'var') && isfield(out, 'out_p')
    p_raw = out.out_p.Data;
    t_raw = out.out_p.Time;
else
    error('找不到 out_p，请先运行 Simulink');
end

if exist('out_pr', 'var')
    pr_raw = out_pr.Data;
elseif exist('out', 'var') && isfield(out, 'out_pr')
    pr_raw = out.out_pr.Data;
else
    error('找不到 out_pr');
end

% --- 2. 核心修复：处理 3D 数组问题 (两个都要检查！) ---
% 检查实际轨迹 p
if ndims(p_raw) == 3
    % 将 3x1xN 转换为 Nx3
    p_raw = squeeze(p_raw)';
end

% 检查参考轨迹 pr
if ndims(pr_raw) == 3
    % 将 3x1xN 转换为 Nx3
    pr_raw = squeeze(pr_raw)';
end

% --- 3. 再次确保长度对齐 ---
len_p = size(p_raw, 1);
len_pr = size(pr_raw, 1);
len = min(len_p, len_pr);

p_data = p_raw(1:len, :);
pr_data = pr_raw(1:len, :);
t_data = t_raw(1:len);

fprintf('数据处理完毕: 最终维度均为 %d x %d\n', size(p_data,1), size(p_data,2));

% --- 4. 定义偏差 (需与 init_single.m 一致) ---
delta = [1; 1; 0]; 

% --- 5. 画图 ---
figure(1); clf; 
set(gcf, 'Color', 'w');

% 子图1: 3D 轨迹
subplot(1,2,1); hold on; grid on; axis equal;
plot3(pr_data(:,1), pr_data(:,2), pr_data(:,3), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Leader (Ref)');
plot3(p_data(:,1), p_data(:,2), p_data(:,3), 'r-', 'LineWidth', 2, 'DisplayName', 'Follower');
% 标记起点和终点
plot3(p_data(1,1), p_data(1,2), p_data(1,3), 'ro', 'MarkerFaceColor', 'r'); 
plot3(p_data(end,1), p_data(end,2), p_data(end,3), 'r*'); 
view(3); 
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('3D Trajectory Tracking');
legend;

% 子图2: 误差曲线
err_x = p_data(:,1) - pr_data(:,1) - delta(1);
err_y = p_data(:,2) - pr_data(:,2) - delta(2);
err_z = p_data(:,3) - pr_data(:,3) - delta(3);

subplot(1,2,2); 
plot(t_data, err_x, 'r', 'LineWidth', 1.5); hold on;
plot(t_data, err_y, 'g', 'LineWidth', 1.5);
plot(t_data, err_z, 'b', 'LineWidth', 1.5);
grid on;
legend('Error X', 'Error Y', 'Error Z');
xlabel('Time (s)'); ylabel('Error (m)');
title('Position Tracking Error');