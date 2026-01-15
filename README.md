# Linux Resource Monitor

一个类似 `top` 的 Linux 资源监控工具，用于实时监控系统资源使用情况。

A `top`-like Linux resource monitoring tool for real-time system resource monitoring.

## 功能特性 (Features)

- 📊 实时监控系统 CPU 和内存使用情况
- 🔝 显示前 10 个占用资源最多的进程
- 👤 详细列出每个进程的用户、PID 和启动命令
- 🔄 自动实时更新，类似 `top` 命令
- 👥 支持切换到用户聚合模式，查看每个用户的总资源用量
- ⌨️ 简单的键盘控制
- ⚡ 提供高性能的 Shell 脚本版本，无需 Python 依赖
- 📦 支持 Debian 包安装

## 安装 (Installation)

### 方法 1: Debian 包安装 (Method 1: Debian Package Installation) - 推荐 (Recommended)

```bash
# 克隆仓库 (Clone the repository)
git clone https://github.com/moolean/linux_resource_monitor.git
cd linux_resource_monitor

# 构建 Debian 包 (Build the Debian package)
./build-deb.sh

# 安装 Debian 包 (Install the Debian package)
sudo dpkg -i linux-resource-monitor_1.0.0_all.deb
```

安装后可直接使用 (After installation, you can use):
- `resource_monitor.sh` - Shell 脚本版本（高性能，无需 Python）
- `resource_monitor.py` - Python 版本（需要 psutil 库）

### 方法 2: 直接运行 Shell 脚本 (Method 2: Run Shell Script Directly) - 高性能 (High Performance)

Shell 脚本版本使用原生 Linux 命令，性能更好，无需安装任何依赖。

```bash
# 克隆仓库 (Clone the repository)
git clone https://github.com/moolean/linux_resource_monitor.git
cd linux_resource_monitor

# 赋予执行权限 (Make executable)
chmod +x resource_monitor.sh

# 运行 (Run)
./resource_monitor.sh
```

### 方法 3: Python 版本 (Method 3: Python Version)

#### 依赖要求 (Requirements)

- Python 3.6+
- psutil 库

#### 安装步骤 (Setup)

```bash
# 克隆仓库 (Clone the repository)
git clone https://github.com/moolean/linux_resource_monitor.git
cd linux_resource_monitor

# 安装依赖 (Install dependencies)
pip install -r requirements.txt

# 赋予执行权限 (Make executable)
chmod +x resource_monitor.py
```

## 使用方法 (Usage)

### Shell 脚本版本 (Shell Script Version) - 推荐 (Recommended)

Shell 脚本版本性能更好，适合在生产环境中使用。

```bash
./resource_monitor.sh
```

如果已安装 Debian 包 (If installed via Debian package):

```bash
resource_monitor.sh
```

### Python 版本 (Python Version)

```bash
./resource_monitor.py
```

或者 (or):

```bash
python3 resource_monitor.py
```

如果已安装 Debian 包 (If installed via Debian package):

```bash
resource_monitor.py
```

### 键盘控制 (Keyboard Controls)

| 按键 (Key) | 功能 (Function) |
|-----------|----------------|
| `p` | 切换到进程监控模式 (Switch to Process monitoring mode) |
| `u` | 切换到用户聚合模式 (Switch to User aggregation mode) |
| `c` | 按 CPU 使用率排序 (Sort by CPU usage) |
| `m` | 按内存使用率排序 (Sort by Memory usage) |
| `q` | 退出程序 (Quit the program) |

## 显示界面 (Display Interface)

### 进程监控模式 (Process Monitoring Mode)

在此模式下，显示占用资源最多的前 10 个进程：

```
Linux Resource Monitor - 2026-01-13 15:43:27
Uptime: 02:15:30 | CPU: 15.3% | Memory: 45.2% (3.6GB/8.0GB)
----------------------------------------------------------------
Mode: PROCESS | Sort: CPU
[p]Process [u]User [c]CPU [m]Memory [q]Quit
----------------------------------------------------------------
PID      USER         CPU%     MEM%     COMMAND
----------------------------------------------------------------
1234     john         25.3     5.2      /usr/bin/python3 app.py
5678     root         15.1     3.8      /usr/sbin/mysqld
...
```

### 用户聚合模式 (User Aggregation Mode)

在此模式下，显示每个用户的总资源使用情况：

```
Linux Resource Monitor - 2026-01-13 15:43:27
Uptime: 02:15:30 | CPU: 15.3% | Memory: 45.2% (3.6GB/8.0GB)
----------------------------------------------------------------
Mode: USER | Sort: CPU
[p]Process [u]User [c]CPU [m]Memory [q]Quit
----------------------------------------------------------------
USER             PROCESSES    TOTAL CPU%   TOTAL MEM%
----------------------------------------------------------------
john             15           45.8         12.5
root             98           35.2         8.3
...
```

## 技术实现 (Technical Details)

### Shell 脚本版本 (Shell Script Version)
- 使用原生 Linux 命令（`ps`, `top`, `free`, etc.）
- 无需外部依赖，性能更好
- 使用 ANSI 转义序列实现终端界面
- 每 0.5 秒自动刷新数据

### Python 版本 (Python Version)
- 使用 `psutil` 库获取系统和进程信息
- 使用 `curses` 库实现终端用户界面
- 每 0.5 秒自动刷新数据
- 支持动态终端窗口大小调整

## 性能对比 (Performance Comparison)

- **Shell 脚本版本**: 直接使用 Linux 命令，性能最佳，CPU 占用更低，适合生产环境
- **Python 版本**: 功能更丰富，代码更易维护，但性能稍低

推荐在生产环境使用 Shell 脚本版本以获得最佳性能。(Recommended to use Shell script version in production for best performance.)

## 许可证 (License)

MIT License

## 贡献 (Contributing)

欢迎提交 Issue 和 Pull Request！

Issues and Pull Requests are welcome!