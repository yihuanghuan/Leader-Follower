%% init_multi.m - 多机编队参数初始化 (支持快捷拓扑修改)
clear; clc;

% --- 1. 物理参数 (所有无人机相同) ---
num_agents = 4; % 无人机数量
m = 1; 
g = 9.81; 
J = diag([0.04856, 0.04856, 0.08801]); 
e3 = [0; 0; 1];

% --- 2. 通信拓扑定义 (快捷修改区) ---
% [快捷修改] 定义领航者 (Node 0) 连向谁？
% 例如: [1] 表示 0->1; [1, 4] 表示 0->1 和 0->4
leader_connections = [1]; 

% [快捷修改] 定义 Follower 之间的连接 (双向/无向)
% 每一行代表一条边: [i, j] 表示 i <-> j
% 当前结构: 1-2, 2-3, 2-4 (对应论文结构)
follower_edges = [ ...
    1, 2;
    2, 3;
    2, 4 ...
    ];

% === 自动生成矩阵 (无需修改) ===
% 1. 生成 d0 向量 (谁连领航者)
d0 = zeros(num_agents, 1);
d0(leader_connections) = 1; 

% 2. 生成 D 矩阵 (邻接矩阵)
D = zeros(num_agents, num_agents);
for k = 1:size(follower_edges, 1)
    i = follower_edges(k, 1);
    j = follower_edges(k, 2);
    D(i, j) = 1;
    D(j, i) = 1; % 自动保证对称性 (无向图)
end

% 3. 生成 M 矩阵 (交互矩阵 M = L + D0)
L = zeros(num_agents, num_agents);
for i = 1:num_agents
    L(i,i) = sum(D(i,:)); % 度矩阵
    for j = 1:num_agents
        if D(i,j) == 1
            L(i,j) = -1;
        end
    end
end
M = L + diag(d0);

% --- 3. 期望编队偏差 delta (对应论文 IV 中的设置) ---
% delta 是 3x4 矩阵，每一列代表一架飞机的偏差 [dx; dy; dz]
delta = zeros(3, 4);
delta(:,1) = [ 1;  1; 0];
delta(:,2) = [-1;  1; 0];
delta(:,3) = [-1; -1; 0];
delta(:,4) = [ 1; -1; 0];

% --- 4. 初始状态 (对应论文 IV 中的设置) ---
% 我们使用 3x4 矩阵来存储位置和速度
% p0_all: [p1, p2, p3, p4]
p0_all = [ 5,  9,  4, -1; 
           3, -4, -2,  4; 
          -1,  1, -3, -2]; 

v0_all = zeros(3, 4); % 初始速度全为0
w0_all = zeros(3, 4); % 初始角速度全为0
Q0_all = repmat([1; 0; 0; 0], 1, 4); % 初始姿态全为水平

% 将所有状态打包，方便 Simulink 读取 (13x4 矩阵)
xInitial = [p0_all; v0_all; Q0_all; w0_all];

% --- 5. 估计器初始状态 ---
rho0 = zeros(3, 4);
a_hat0 = zeros(3, 4);

% --- 6. 控制参数 (来自论文) ---
kp = 3;  kv = 3;
k_rho = 0.5; % 估计器参数
ka = 30;     % 估计器参数
kq = 16;     % 估计器参数
kt = 20;     % 姿态环参数
kw = 3;      % 姿态环参数

alpha = 0.5; % 有限时间收敛参数 epsilon(t) 的衰减率

% --- 7. 仿真设置 ---
sim_time = 80;
dt = 0.001;

fprintf('参数初始化完成！\n已生成 %d 个智能体的拓扑结构。\n', num_agents);