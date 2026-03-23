#!/bin/bash
# deploy/setup.sh — 在騰訊雲伺服器上執行一次即可
# 使用方式：bash setup.sh

set -e

echo "==> 建立目錄"
mkdir -p /opt/dino-runner/web

echo "==> 安裝 Node.js（如已安裝會跳過）"
if ! command -v node &> /dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
    yum install -y nodejs || apt-get install -y nodejs
fi
node -v

echo "==> 安裝 PM2"
npm install -g pm2

echo "==> 安裝 server 依賴"
cd /opt/dino-runner
npm install

echo "==> 啟動 / 重啟 Node.js server"
pm2 delete dino-runner 2>/dev/null || true
pm2 start server.js --name dino-runner
pm2 save
pm2 startup | tail -1    # 複製輸出的指令並執行，確保開機自啟

echo "==> 安裝 Nginx（如已安裝會跳過）"
yum install -y nginx 2>/dev/null || apt-get install -y nginx

echo "==> 部署 Nginx 設定"
cp /opt/dino-runner/dino-runner.nginx.conf /etc/nginx/conf.d/dino-runner.conf
nginx -t && systemctl reload nginx || systemctl start nginx
systemctl enable nginx

echo ""
echo "✅ 完成！遊戲已在 http://43.156.79.28 上線"
echo "   API：http://43.156.79.28/api/leaderboard"
