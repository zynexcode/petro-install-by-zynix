#!/bin/bash

clear

# Colors
RED='\033[0;31m'
GRN='\033[0;32m'
CYN='\033[0;36m'
YEL='\033[1;33m'
NC='\033[0m' # No Color

# ASCII Art Banner (Zynex Code Branding)
echo -e "${YEL}"
cat << "EOF"
  ______ __     __  _   _   ______  __   __
 |___  / \ \   / / | \ | | |  ____| \ \ / /
    / /   \ \_/ /  |  \| | | |__     \ V / 
   / /     \   /   | . ` | |  __|     > <  
  / /__     | |    | |\  | | |____   / . \ 
 /_____|    |_|    |_| \_| |______| /_/ \_\
                                           
            🔥 ZYNEX CODE 🔥
EOF
echo -e "${NC}"

# Subscribe animation
echo -ne "${GRN}✨ RasIN ki JaaH ✨\n"
for i in {1..3}; do
  echo -ne "${CYN}Subscribing To Zynex Code"
  for dot in {1..3}; do
    echo -n "."
    sleep 0.3
  done
  echo -ne "\r                             \r"
done
echo -e "${GRN}✅ Thanks for Subscribing to Zynex Code!${NC}\n"
sleep 1

# Blueprint installation
cd ~/blueprints || { echo -e "${RED}❌ blueprints folder not found!${NC}"; exit 1; }

blueprints=(
  "snowflakes.blueprint"
  "mcplugin.blueprint"
  "loader.blueprint"
  "minecraftplayermanager.blueprint"
  "nightadmin.blueprint"
  "versionchanger.blueprint"
  "huxregister.blueprint"
)

for bp in "${blueprints[@]}"; do
  if [ -f "$bp" ]; then
    mv "$bp" /var/www/pterodactyl/ || { echo -e "${RED}❌ Failed to move $bp${NC}"; continue; }
    cd /var/www/pterodactyl || exit 1
    blueprint -install "$bp" || echo -e "${RED}❌ Failed to install $bp${NC}"
  else
    echo -e "${YEL}⚠️  $bp not found, skipping...${NC}"
  fi
done

echo -e "${GRN}🚀 Installation complete by Zynex Code!${NC}"

