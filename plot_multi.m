%% plot_multi.m - 多机编队绘图 (含拓扑可视化)
clear p_data pr_data t_data; clc;

% --- 1. 读取数据 ---
if exist('out_p', 'var')
    p_raw = out_p.Data; 
    t_raw = out_p.Time;
elseif exist('out', 'var') && isfield(out, 'out_p')
    p_raw = out.out_p.Data;
    t_raw = out.out_p.Time;
else
    error('找不到 out_p，请先运行 Simulink (Multi_Quad.slx)');
end

if exist('out_pr', 'var')
    pr_raw = out_pr.Data;
elseif exist('out', 'var') && isfield(out, 'out_pr')
    pr_raw = out.out_pr.Data;
else
    error('找不到 out_pr');
end

% --- 2. 维度处理 ---
[dim1, num_agents, len_raw] = size(p_raw);

% 截取 pr 的长度使其对齐
len = min(len_raw, size(pr_raw, 3)); 
if ndims(pr_raw) == 2 
    len = min(len_raw, size(pr_raw, 1));
end

t_data = t_raw(1:len);

% 提取参考轨迹
if ndims(pr_raw) == 3
    pr_data = squeeze(pr_raw)'; 
else
    pr_data = pr_raw;
end
pr_data = pr_data(1:len, :);

% 提取 4 架飞机的轨迹
p_agent = cell(1, num_agents);
for i = 1:num_agents
    temp = p_raw(:, i, 1:len);
    p_agent{i} = squeeze(temp)';
end

% --- 3. Figure 1: 3D 轨迹与队形 ---
figure(1); clf; 
set(gcf, 'Color', 'w', 'Name', '3D Trajectory');
hold on; grid on; axis equal; view(3);

colors = {'r', 'b', 'g', 'm'}; 
markers = {'*', 'd', 's', '^'};

% 画参考轨迹
plot3(pr_data(:,1), pr_data(:,2), pr_data(:,3), 'k--', 'LineWidth', 1.5, 'DisplayName', 'Reference');

% 画 4 架飞机的轨迹
for i = 1:num_agents
    plot3(p_agent{i}(:,1), p_agent{i}(:,2), p_agent{i}(:,3), ...
          'Color', colors{i}, 'LineWidth', 1.5, ...
          'DisplayName', ['Agent ' num2str(i)]);
end

% 画"快照"连线 (每隔一段画一个多边形)
snapshot_indices = round(linspace(1, len, 6)); 
for idx = snapshot_indices
    pts = zeros(3, num_agents);
    for i = 1:num_agents
        pts(:,i) = p_agent{i}(idx, :)';
    end
    % 简单的环形连线以显示相对位置
    line_order = [1, 2, 3, 4, 1]; 
    line(pts(1, line_order), pts(2, line_order), pts(3, line_order), ...
         'Color', [0.6 0.6 0.6], 'LineWidth', 0.5);
    % 标记
    for i = 1:num_agents
        plot3(pts(1,i), pts(2,i), pts(3,i), markers{i}, 'Color', colors{i}, 'MarkerSize', 6);
    end
end
xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)');
title('Multi-Agent Formation Tracking');
legend('Location', 'best');

% --- 4. Figure 2: 误差曲线 ---
figure(2); clf;
set(gcf, 'Color', 'w', 'Name', 'Tracking Errors');

% 需要读取 delta (如果 workspace 里没有，则使用默认值防止报错)
if ~exist('delta', 'var')
    delta = zeros(3, 4); % 默认无偏差
    warning('未找到 delta 变量，误差计算可能不含编队偏移。');
end

for i = 1:num_agents
    err = p_agent{i} - pr_data - delta(:,i)';
    
    subplot(3,1,1); hold on; grid on;
    plot(t_data, err(:,1), 'Color', colors{i}); ylabel('Ex (m)'); title('Position Error X');
    
    subplot(3,1,2); hold on; grid on;
    plot(t_data, err(:,2), 'Color', colors{i}); ylabel('Ey (m)'); title('Position Error Y');
    
    subplot(3,1,3); hold on; grid on;
    plot(t_data, err(:,3), 'Color', colors{i}); ylabel('Ez (m)'); title('Position Error Z');
end
xlabel('Time (s)');

% --- 5. Figure 3: 通信拓扑图 (自动绘制) ---
if exist('D', 'var') && exist('d0', 'var')
    figure(3); clf; 
    set(gcf, 'Color', 'w', 'Name', 'Communication Topology');
    
    num_agents = size(D, 1);
    
    % 构建全系统邻接矩阵 (包含领航者 Node 0)
    Adj_Full = zeros(num_agents + 1);
    Adj_Full(2:end, 2:end) = D;   % Follower 间连接
    Adj_Full(1, 2:end) = d0';     % Leader -> Follower
    
    % 创建图对象
    NodeNames = [{'0 (Leader)'}, arrayfun(@(x) sprintf('%d', x), 1:num_agents, 'UniformOutput', false)];
    G = digraph(Adj_Full, NodeNames);
    
    % 绘图
    p = plot(G, 'Layout', 'layered'); 
    
    % 美化
    p.MarkerSize = 10;
    p.NodeColor = [0 0.4470 0.7410];
    p.EdgeColor = [0.4 0.4 0.4];
    p.LineWidth = 1.5;
    p.ArrowSize = 12;
    p.NodeFontSize = 12;
    
    % 高亮领航者
    highlight(p, '0 (Leader)', 'NodeColor', 'r', 'MarkerSize', 12);
    
    title('Current Communication Topology');
    axis off;
else
    fprintf('未找到 D 或 d0 矩阵，跳过拓扑图绘制。\n');
end