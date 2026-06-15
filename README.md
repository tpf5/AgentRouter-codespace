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

## 目录结构

```
.devcontainer/devcontainer.json   # 开发容器配置（地址、模型、自动加载 .env）
.env.example                      # 第三方令牌模板（复制为 .env 使用）
requirements.txt                  # Python 依赖（按需）
```
