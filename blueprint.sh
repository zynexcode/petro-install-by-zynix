#!/bin/bash

clear
echo "   _____ _    _ _____ _    _          __  __ "
echo "  / ____| |  | |_   _| |  | |   /\   |  \/  |"
echo " | (___ | |__| | | | | |__| |  /  \  | \  / |"
echo "  \___ \|  __  | | | |  __  | / /\ \ | |\/| |"
echo "  ____) | |  | |_| |_| |  | |/ ____ \| |  | |"
echo " |_____/|_|  |_|_____|_|  |_/_/    \_\_|  |_|"

echo Starting Installation

sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs
npm i -g yarn
cd /var/www/pterodactyl
yarn
apt install -y zip unzip git curl wget
wget "$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4)" -O release.zip
unzip release.zip
chmod +x blueprint.sh
bash blueprint.sh

echo Now you can use blueprint extensions! :tada:
Enjoy!