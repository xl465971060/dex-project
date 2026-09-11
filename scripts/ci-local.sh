#!/usr/bin/env bash
# 本地复刻 CI（.github/workflows/ci.yml）的全部检查——推送前跑一遍，
# 避免“push → 等 3 分钟 → 红了 → 修 → 重推”的循环。
# 用法：bash scripts/ci-local.sh   （不需要 anvil / 数据库 / GitHub 远程）

set -euo pipefail
cd "$(dirname "$0")/.."

# forge/anvil 装在 ~/.foundry/bin；脚本（非交互 shell）不会读 ~/.bashrc 的 PATH，手动补上
export PATH="$PATH:$HOME/.foundry/bin"

echo "==> [1/5] 模拟 CI 的严格安装（--frozen-lockfile：lockfile 和 package.json 不同步会立刻报错）"
pnpm install --frozen-lockfile

echo "==> [2/5] contracts job：子模块 + forge build/test"
git submodule update --init --recursive
pnpm --filter @perpdex/contracts build
pnpm --filter @perpdex/contracts test

echo "==> [3/5] db:generate（仅当 prisma 与 schema 都已就位；周5 前自动跳过）"
if [ -f apps/api/prisma/schema.prisma ] && pnpm --filter @perpdex/api exec prisma --version >/dev/null 2>&1; then
  pnpm --filter @perpdex/api db:generate
else
  echo "    （未装 prisma 或无 schema，跳过——对应 CI 里被注释的 db:generate 行）"
fi

echo "==> [4/5] app job：turbo build test typecheck（排除 contracts）"
pnpm turbo build test typecheck --filter='!@perpdex/contracts'

echo "==> [5/5] ✅ 本地 CI 全绿，可以 git push 了"