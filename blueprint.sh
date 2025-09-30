#!/bin/bash

# =======================================
#   RasIN Blueprints (RG) - Auto Install
#   Powered by RasIN
# =======================================

set -e
trap 'echo "❌ Error occurred at line $LINENO. Exiting..."; exit 1' ERR

# --- Logo Banner ---
logo_banner() {
cat << "EOF"
  ______ __     __  _   _   ______  __   __
 |___  / \ \   / / | \ | | |  ____| \ \ / /
    / /   \ \_/ /  |  \| | | |__     \ V / 
   / /     \   /   | . ` | |  __|     > <  
  / /__     | |    | |\  | | |____   / . \ 
 /_____|    |_|    |_| \_| |______| /_/ \_\
                                           
          🔥 zynIX CODE 🔥
EOF
}

# --- Root Check ---
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Please run this script as root (use sudo)."
    exit 1
fi

clear
logo_banner
echo ">>> 🚀 Starting RasIN Blueprints (RG) Setup..."

# Step 1: Install Node.js 20.x
echo ">>> Installing Node.js 20.x..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
  gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | \
  tee /etc/apt/sources.list.d/nodesource.list > /dev/null
apt-get update -y
apt-get install -y nodejs

# Step 2: Install Yarn & dependencies
echo ">>> Installing dependencies..."
npm install -g yarn
apt-get install -y zip unzip git wget

# Step 3: Setup in Pterodactyl directory
if [ ! -d "/var/www/pterodactyl" ]; then
    echo "❌ Pterodactyl directory not found!"
    exit 1
fi

cd /var/www/pterodactyl
yarn install

# Step 4: Download RasIN Hosting release
echo ">>> Downloading latest RasIN Hosting release..."
release_url=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | \
grep 'browser_download_url' | cut -d '"' -f 4 | head -n 1)

if [ -z "$release_url" ]; then
    echo "❌ Failed to fetch release URL from GitHub."
    exit 1
fi

wget -O release.zip "$release_url"

echo ">>> Extracting release files..."
unzip -o release.zip

# Step 5: Run blueprint.sh
if [ ! -f "blueprint.sh" ]; then
    echo "❌ Error: blueprint.sh not found in release package."
    exit 1
fi

chmod +x blueprint.sh
echo ">>> Running blueprint.sh for RasIN Blueprints..."
bash blueprint.sh

echo "✅ RasIN Blueprints (RG) setup completed successfully!"


