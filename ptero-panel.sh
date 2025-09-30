#!/bin/bash

# Hide commands and log output
exec > >(tee -i install.log) 2>&1
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ASCII Art
echo -e "${YELLOW}"
cat << "EOF"

  ______ __     __  _   _   ______  __   __
 |___  / \ \   / / | \ | | |  ____| \ \ / /
    / /   \ \_/ /  |  \| | | |__     \ V / 
   / /     \   /   | . ` | |  __|     > <  
  / /__     | |    | |\  | | |____   / . \ 
 /_____|    |_|    |_| \_| |______| /_/ \_\


EOF
echo -e "${NC}"

TOTAL_STEPS=9
current_step=0

progress_bar() {
    current_step=$((current_step + 1))
    percent=$((current_step * 100 / TOTAL_STEPS))
    printf "\r${BLUE}[${NC}"
    for ((i=0; i<percent/2; i++)); do printf "▓"; done
    for ((i=percent/2; i<50; i++)); do printf " "; done
    printf "${BLUE}] ${percent}%% ${NC}(${current_step}/${TOTAL_STEPS}) ${GREEN}$1${NC}\n"
}

execute() {
    eval "$1" >/dev/null 2>&1
}

echo -e "${YELLOW}🚀 Starting Pterodactyl Panel Installation (Codesandbox method)...${NC}\n"

# Step 1: apt update
progress_bar "Updating package lists..."
execute "apt update -y"

# Step 2: Install required packages
progress_bar "Installing prerequisites..."
execute "apt install -y apt-transport-https ca-certificates curl software-properties-common"

# Step 3: Install Docker Compose
progress_bar "Installing Docker Compose..."
execute "apt install -y docker-compose"

# Step 4: Create directories
progress_bar "Creating directories..."
execute "mkdir -p pterodactyl/panel"
cd pterodactyl/panel

# Step 5: Create docker-compose.yml
progress_bar "Creating docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

x-common:
  database:
    &db-environment
    MYSQL_PASSWORD: &db-password "CHANGE_ME"
    MYSQL_ROOT_PASSWORD: "CHANGE_ME_TOO"
  panel:
    &panel-environment
    APP_URL: "https://pterodactyl.example.com"
    APP_TIMEZONE: "UTC"
    APP_SERVICE_AUTHOR: "noreply@example.com"
    TRUSTED_PROXIES: "*"
  mail:
    &mail-environment
    MAIL_FROM: "noreply@example.com"
    MAIL_DRIVER: "smtp"
    MAIL_HOST: "mail"
    MAIL_PORT: "1025"
    MAIL_USERNAME: ""
    MAIL_PASSWORD: ""
    MAIL_ENCRYPTION: "true"

services:
  database:
    image: mariadb:10.5
    restart: always
    command: --default-authentication-plugin=mysql_native_password
    volumes:
      - "./data/database:/var/lib/mysql"
    environment:
      <<: *db-environment
      MYSQL_DATABASE: "panel"
      MYSQL_USER: "pterodactyl"

  cache:
    image: redis:alpine
    restart: always

  panel:
    image: ghcr.io/pterodactyl/panel:latest
    restart: always
    ports:
      - "8030:80"
      - "4433:443"
    links:
      - database
      - cache
    volumes:
      - "./data/var:/app/var"
      - "./data/nginx:/etc/nginx/http.d"
      - "./data/certs:/etc/letsencrypt"
      - "./data/logs:/app/storage/logs"
    environment:
      <<: [*panel-environment, *mail-environment]
      DB_PASSWORD: *db-password
      APP_ENV: "production"
      APP_ENVIRONMENT_ONLY: "false"
      CACHE_DRIVER: "redis"
      SESSION_DRIVER: "redis"
      QUEUE_DRIVER: "redis"
      REDIS_HOST: "cache"
      DB_HOST: "database"
      DB_PORT: "3306"

networks:
  default:
    ipam:
      config:
        - subnet: 172.20.0.0/16
EOF

# Step 6: Create data directories
progress_bar "Creating data directories..."
execute "mkdir -p ./data/{database,var,nginx,certs,logs}"

# Step 7: Start containers
progress_bar "Starting containers..."
docker-compose up -d

# Step 8: Create admin user
progress_bar "Creating admin user..."
echo -e "${YELLOW}Please enter admin details when prompted:${NC}"
docker-compose run --rm panel php artisan p:user:make

# Step 9: Finalize installation
progress_bar "Finalizing..."
echo -e "\n${GREEN}✅ Installation Completed Successfully!${NC}"
echo -e "${BLUE}Access your panel at:${NC} ${YELLOW}http://localhost:8030${NC}"
echo -e "${RED}⚠️ Remember to change default passwords and configure domain/SSL.${NC}"
