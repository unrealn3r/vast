#!/usr/bin/env bash
set -euo pipefail

echo "=== AI Toolkit Provisioning Script ==="
LOG="/var/log/ai-toolkit-provision.log"
exec > >(tee -a "$LOG") 2>&1

INSTALL_DIR="/workspace/ai-toolkit"
PORT="${PORT:-8675}"

echo "[1/6] Checking prerequisites..."
command -v git >/dev/null || { echo "Error: git missing"; exit 1; }
command -v python3 >/dev/null || { echo "Error: python3 missing"; exit 1; }

# Node.js / npm check
if ! command -v npm >/dev/null; then
  echo "Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi

echo "[2/6] Cloning AI Toolkit..."
if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "Repo exists, updating..."
  git -C "$INSTALL_DIR" pull --ff-only || true
else
  git clone --depth 1 https://github.com/ostris/ai-toolkit.git "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

echo "[3/6] Setting up Python environment..."
if [[ ! -d "venv" ]]; then
  python3 -m venv venv
fi
source venv/bin/activate

echo "[4/6] Installing dependencies..."
pip install --upgrade pip
pip install --no-cache-dir torch==2.13.0 torchvision==0.28.0 torchaudio==2.11.0 \
  --index-url https://download.pytorch.org/whl/cu130
pip install -r requirements.txt

echo "[5/6] Building UI and initializing database..."
cd ui
npm install
npm run build

# Initialize Prisma database (fixes "Queue does not exist" error)
npx prisma generate
npx prisma db push || true

# Fix permissions
mkdir -p "$INSTALL_DIR/output" "$INSTALL_DIR/config" "$INSTALL_DIR/datasets" "$INSTALL_DIR/jobs"
chmod -R 777 "$INSTALL_DIR"

echo "[6/6] Starting AI Toolkit UI..."

# Kill any existing process on the port
fuser -k "${PORT}/tcp" 2>/dev/null || true
pkill -9 -f "npm run start" 2>/dev/null || true
pkill -9 -f node 2>/dev/null || true
sleep 2

# Start in background
cd "$INSTALL_DIR/ui"
nohup npm run start > /var/log/ai-toolkit-ui.log 2>&1 &

# Clear Vast.ai provisioning lock
rm -f /.provisioning /workspace/.provisioning 2>/dev/null || true

echo "=== Provisioning complete ==="
echo "UI logs: /var/log/ai-toolkit-ui.log"
echo "Access the UI via Vast.ai HTTP proxy on port $PORT"
