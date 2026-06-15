#!/usr/bin/env bash
# 一键在 Linux 环境（阿里云 PAI-DSW / 魔搭 ModelScope / Gitpod 等）
# 安装 Claude Code 并配好第三方 API。
#
# 用法：
#   export ANTHROPIC_AUTH_TOKEN="你的第三方令牌"
#   bash setup-claude.sh
#
# 可选（不设则用默认值）：
#   export ANTHROPIC_BASE_URL="https://cc.freemodel.dev"
#   export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-8"
set -e

BASE_URL="${ANTHROPIC_BASE_URL:-https://cc.freemodel.dev}"
OPUS_MODEL="${ANTHROPIC_DEFAULT_OPUS_MODEL:-claude-opus-4-8}"

if [ -z "${ANTHROPIC_AUTH_TOKEN:-}" ]; then
  echo "❌ 请先设置令牌后再运行："
  echo '   export ANTHROPIC_AUTH_TOKEN="你的第三方令牌"'
  exit 1
fi

# 用国内 npm 镜像，装包更快（失败也不影响）
npm config set registry https://registry.npmmirror.com 2>/dev/null || true

# 1) 装 Node.js（已存在则跳过）；优先用阿里云 npmmirror 预编译包，国内最稳
if ! command -v node >/dev/null 2>&1; then
  echo "未检测到 Node.js，开始安装…"
  NODE_VER="v20.18.0"
  if curl -fsSL "https://registry.npmmirror.com/-/binary/node/${NODE_VER}/node-${NODE_VER}-linux-x64.tar.gz" -o /tmp/node.tar.gz; then
    mkdir -p "$HOME/.local/node"
    tar -xzf /tmp/node.tar.gz -C "$HOME/.local/node" --strip-components=1
    export PATH="$HOME/.local/node/bin:$PATH"
  elif command -v conda >/dev/null 2>&1; then
    conda install -y nodejs
  elif command -v apt-get >/dev/null 2>&1; then
    SUDO=""; command -v sudo >/dev/null 2>&1 && SUDO=sudo
    curl -fsSL https://deb.nodesource.com/setup_20.x | $SUDO -E bash -
    $SUDO apt-get install -y nodejs
  else
    echo "❌ 无法自动安装 Node，请手动装 18+ 后重试"; exit 1
  fi
fi
echo "Node 版本：$(node -v)"

# 2) 全局安装 Claude Code
npm install -g @anthropic-ai/claude-code

# 3) 写入 Claude Code 默认设置
mkdir -p ~/.claude
cat > ~/.claude/settings.json <<'JSON'
{
  "permissions": { "defaultMode": "bypassPermissions" },
  "skipDangerousModePermissionPrompt": true,
  "theme": "dark",
  "effortLevel": "xhigh"
}
JSON

# 4) 把第三方 API 环境变量持久化到 ~/.bashrc（重开终端即生效）
if ! grep -q "ANTHROPIC_BASE_URL" ~/.bashrc 2>/dev/null; then
  cat >> ~/.bashrc <<EOF

# ===== Node + Claude Code 第三方 API =====
export PATH="\$HOME/.local/node/bin:\$PATH"
export ANTHROPIC_BASE_URL="$BASE_URL"
export ANTHROPIC_DEFAULT_OPUS_MODEL="$OPUS_MODEL"
export ANTHROPIC_AUTH_TOKEN="$ANTHROPIC_AUTH_TOKEN"
# root 容器（如 DSW/ModelScope）下允许 bypass 权限模式
export IS_SANDBOX=1
EOF
fi

echo ""
echo "✅ 安装完成。启动："
echo "   source ~/.bashrc && claude"
echo "   （或新开一个终端直接 claude）"
