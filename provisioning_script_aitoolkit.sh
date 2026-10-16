#!/usr/bin/env bash
set -euo pipefail

echo "=== AI Toolkit Provisioning Script ==="
LOG="/var/log/ai-toolkit-provision.log"
exec > >(tee -a "$LOG") 2>&1

INSTALL_DIR="/workspace/ai-toolkit"
PORT="${PORT:-8675}"

echo "[1/5] Checking prerequisites..."
command -v git >/dev/null || { echo "Error: git missing"; exit 1; }
command -v python3 >/dev/null || { echo "Error: python3 missing"; exit 1; }

# Node.js / npm check (install if missing)
if ! command -v npm >/dev/null; then
  echo "Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi

echo "[2/5] Cloning AI Toolkit..."
if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "Repo exists, updating..."
  git -C "$INSTALL_DIR" pull --ff-only || true
else
  git clone --depth 1 https://github.com/ostris/ai-toolkit.git "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

echo "[3/5] Setting up Python environment..."
if [[ ! -d "venv" ]]; then
  python3 -m venv venv
fi
source venv/bin/activate

echo "[4/5] Installing dependencies..."
pip install --upgrade pip
pip install --no-cache-dir torch==2.13.0 torchvision==0.28.0 torchaudio==2.11.0 \
  --index-url https://download.pytorch.org/whl/cu130
pip install -r requirements.txt

echo "[5/5] Building UI..."
cd ui
npm install
npm run build

echo "=== Starting AI Toolkit UI on port $PORT ==="

# Start in background so provisioning can finish
cd /workspace/ai-toolkit/ui
nohup npm run start > /var/log/ai-toolkit-ui.log 2>&1 &

# Clear Vast.ai provisioning lock so the instance finishes starting
rm -f /.provisioning /workspace/.provisioning 2>/dev/null || true

echo "=== Provisioning complete ==="
echo "UI logs: /var/log/ai-toolkit-ui.log"
echo "Access the UI via Vast.ai HTTP proxy on port $PORT"
