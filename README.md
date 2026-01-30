# UAV Leader-Follower Formation Control (无人机领航-跟随编队控制)

## 📖 项目简介 (Introduction)
本项目基于 MATLAB/Simulink 开发，实现了一个多四旋翼无人机（Quadrotor）的**领航-跟随（Leader-Follower）**编队控制系统。

工程包含单机跟踪（Single Agent）与多机编队（Multi-Agent）两套仿真环境，主要验证了基于一致性理论的编队控制算法。通过 Simscape Multibody 或动力学方程搭建无人机模型，并实现了 3D 轨迹的可视化与误差分析。

### ✨ 主要功能
* **多机编队控制**：支持 4 架无人机组成菱形/方形编队跟随虚拟领航者。
* **灵活的拓扑结构**：在 `init_multi.m` 中可快速自定义通信拓扑（邻接矩阵），代码自动生成拉普拉斯矩阵 ($L$) 和交互矩阵 ($M$)。
* **自动化绘图**：
    * 3D 动态轨迹与队形快照。
    * X/Y/Z 三轴位置跟踪误差分析。
    * **自动生成通信拓扑图**（基于 `digraph`）。

## 📂 文件结构 (File Structure)

```text
├── init_multi.m      # [核心] 多机编队初始化：定义物理参数、通信拓扑、初始状态
├── init_single.m     # 单机跟踪初始化：定义单机参数
├── Multi_Quad.slx    # [核心] 多机编队 Simulink 主仿真模型
├── Single_Quad.slx   # 单机跟踪 Simulink 测试模型
├── plot_multi.m      # [核心] 多机结果绘图：绘制3D轨迹、误差曲线及拓扑图
└── plot_single.m     # 单机结果绘图
```

## 🚀 快速开始 (Getting Started)

### 环境要求

- MATLAB R2022a 或更高版本（建议 R2023a+）
- Simulink
- Control System Toolbox（用于控制系统分析）

### 运行步骤 (多机编队)

1. **加载参数**：在 MATLAB 中打开并运行 `init_multi.m`。  
   控制台输出 `参数初始化完成！` 即表示成功。

2. **运行仿真**：打开 `Multi_Quad.slx`，点击 Run 按钮。  
   默认仿真时间为 80 秒。

3. **结果分析**：仿真结束后，运行 `plot_multi.m`。将会弹出三个窗口：
   - Figure 1: 3D 轨迹图（包含队形保持快照）
   - Figure 2: 各无人机的位置跟踪误差
   - Figure 3: 当前的通信拓扑结构图（自动生成）

## ⚙️ 参数配置 (Configuration)

你可以在 `init_multi.m` 中修改以下关键参数：

- **通信拓扑**：修改 `leader_connections` 和 `follower_edges` 数组即可改变无人机之间的连接关系。
- **编队队形**：修改 `delta` 矩阵定义各无人机相对于领航者的期望位置偏移。
- **控制器增益**：修改 `kp`、`kv` 等参数调整控制性能。

## 📝 许可证 (License)

MIT License
