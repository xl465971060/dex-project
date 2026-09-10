#!/usr/bin/env bash
# 在 WSL2 Ubuntu 里安装原生 Docker Engine（不依赖 Windows 的 Docker Desktop）。
# 用法：sudo bash scripts/install-docker.sh   （幂等，可重复运行）
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "请用 sudo 运行：sudo bash scripts/install-docker.sh"
  exit 1
fi

echo "==> 1/5 移除可能冲突的旧包（没装过就自动跳过）"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  apt-get remove -y "$pkg" >/dev/null 2>&1 || true
done

echo "==> 2/5 添加 Docker apt 源（官方源连不上时自动换国内镜像）"
apt-get update -qq
apt-get install -y -qq ca-certificates curl
install -m 0755 -d /etc/apt/keyrings

# 依次尝试：Docker 官方 → 清华 TUNA → 阿里云。
# 国内网络对官方源常发 Connection reset，镜像源用于兜底。
CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
REPO_BASE=""
for base in \
  "https://download.docker.com/linux/ubuntu" \
  "https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu" \
  "https://mirrors.aliyun.com/docker-ce/linux/ubuntu"; do
  echo "  尝试源: $base"
  if curl -fSL --connect-timeout 8 --max-time 30 "$base/gpg" -o /etc/apt/keyrings/docker.asc; then
    REPO_BASE="$base"
    break
  fi
  echo "  × 连不上（Connection reset / 超时），换下一个源"
done
if [[ -z "$REPO_BASE" ]]; then
  echo "✗ 所有 apt 源都连不上。可开 Windows 代理后重试："
  echo "    source scripts/proxy.sh on && sudo -E bash $0"
  exit 1
fi
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
$REPO_BASE $CODENAME stable" \
  > /etc/apt/sources.list.d/docker.list

echo "==> 3/5 安装 Docker Engine + compose 插件"
apt-get update -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> 4/5 启动并设为自启"
if [[ "$(ps -p 1 -o comm=)" == "systemd" ]]; then
  systemctl enable --now docker
else
  service docker start   # WSL 没开 systemd 时的兜底（每次重启 WSL 后需手动跑一次）
fi

echo "==> 5/5 把当前用户加入 docker 组（之后用 docker 不用 sudo）"
if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
  usermod -aG docker "${SUDO_USER}"
fi

echo
docker --version
docker compose version
echo
echo "完成！docker 组要重开终端（或执行 newgrp docker）才生效。"
echo "验证：docker run --rm hello-world"
