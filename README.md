# AI 云端开发环境（GitHub Codespaces + Claude Code）

在 **GitHub Codespaces（免费 CPU）** 里使用 **Claude Code**，并通过**第三方中转 API** 调用模型。

打开 Codespace 时会自动：
- 创建 Python 3.11 + Node.js 20 容器
- 全局安装 Claude Code（`@anthropic-ai/claude-code`）
- 让每个新终端自动加载 `.env`（把第三方令牌注入环境变量）

## 一、创建 Codespace

1. 打开本仓库 GitHub 页面 → 绿色 **`Code`** → **`Codespaces`** → **`Create codespace on main`**
2. 等容器构建（首次约 1-2 分钟），完成后进入网页版 VSCode

> 免费额度：每月 60 核时 + 15GB。**不用时记得 Stop**，避免空跑消耗额度。

## 二、填入第三方令牌（.env）

Codespaces Secret 注入不进来时，改用本地 `.env`（已被 `.gitignore` 忽略，不会提交）。

在 Codespace 终端里：

```bash
cp .env.example .env
```

然后用 VSCode 打开 `.env`，把 `ANTHROPIC_AUTH_TOKEN` 改成你的第三方令牌
（令牌在你本机 `~/.claude/settings.json` 里，形如 `fe_oa_...`）。

## 三、启动 Claude Code

新开一个终端（会自动加载 `.env`），直接运行：

```bash
claude
```

它会带着第三方地址 `https://cc.freemodel.dev` 和令牌启动，即走第三方 API。

> 如果是**当前这个**已经开着的终端（建 `.env` 之前就打开的，还没自动加载），先手动加载一次：
> ```bash
> set -a; source .env; set +a
> claude
> ```

## 四、以后怎么改地址 / 模型 / 令牌

| 改什么 | 改哪里 | 生效方式 |
|--------|--------|---------|
| API 地址 `ANTHROPIC_BASE_URL` | `.devcontainer/devcontainer.json`（入库）和 `.env` | push 后 Rebuild Container |
| 模型名 `ANTHROPIC_DEFAULT_OPUS_MODEL` | 同上 | 同上 |
| 令牌 `ANTHROPIC_AUTH_TOKEN` | **只在 `.env`**（不入库） | 重开终端或 `source .env` |

## 五、在其他平台用（PAI-DSW / ModelScope / Gitpod）

仓库里的 `setup-claude.sh` 是通用安装脚本，适合任何 Linux 终端环境。

### 阿里云 PAI-DSW / 魔搭 ModelScope（免费 GPU，浏览器 Notebook）

这两个是**免费 GPU** 环境，适合真正跑 / 微调模型（ModelScope 的免费实例其实就是 PAI-DSW 提供的）。
开好实例后，在它的终端里：

```bash
git clone https://github.com/tpf308/ai-codespace.git && cd ai-codespace
export ANTHROPIC_AUTH_TOKEN="你的第三方令牌"
bash setup-claude.sh
source ~/.bashrc
claude
```

脚本会自动装 Node + Claude Code、写好默认设置、把第三方 API 变量持久化到 `~/.bashrc`。

### Gitpod（CPU 云 IDE，类似 Codespaces）

1. 先在 👉 https://gitpod.io/variables 设 3 个变量（scope 填 `tpf308/ai-codespace` 或 `*/*`）：
   - `ANTHROPIC_BASE_URL` = `https://cc.freemodel.dev`
   - `ANTHROPIC_DEFAULT_OPUS_MODEL` = `claude-opus-4-8`
   - `ANTHROPIC_AUTH_TOKEN` = 你的令牌
2. 打开 👉 `https://gitpod.io/#https://github.com/tpf308/ai-codespace`
3. 等 `.gitpod.yml` 的任务跑完，终端里运行 `claude`

> 若你用的是新版 Gitpod（基于 devcontainer），它会直接复用本仓库已有的 `.devcontainer/`。

## 目录结构

```
.devcontainer/devcontainer.json    # Codespaces 容器配置（地址、模型、自动加载 .env、写默认设置）
.devcontainer/claude-settings.json # Claude Code 默认设置（权限/主题/强度）
.gitpod.yml                        # Gitpod 配置
setup-claude.sh                    # 通用安装脚本（PAI-DSW / ModelScope 等）
.env.example                       # 第三方令牌模板（复制为 .env 使用）
requirements.txt                   # Python 依赖（按需）
```
