# init.ps1 - CCX 项目初次配置脚本（简洁版 + 端口提示 + 忽略卸载脚本）
# 用法：在项目根目录 (ccx/) 下执行 .\init.ps1

Write-Host "🚀 开始初始化 CCX 项目配置..." -ForegroundColor Cyan

# 1️⃣ 生成高强度随机密钥
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$bytes = New-Object byte[] 32
$rng.GetBytes($bytes)
$generatedKey = -join ($bytes | ForEach-Object { '{0:x2}' -f $_ })

# 2️⃣ 创建持久化目录
Write-Host " 创建持久化目录..." -ForegroundColor Yellow
New-Item -Path ".config", "logs" -ItemType Directory -Force | Out-Null

# 3️⃣ 生成 .env 配置文件
Write-Host "🔑 生成 .env 配置文件..." -ForegroundColor Yellow
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$envContent = @"
PROXY_ACCESS_KEY=$generatedKey
ADMIN_ACCESS_KEY=$generatedKey
APP_UI_LANGUAGE=zh-CN
LOG_LEVEL=warn
ENABLE_WEB_UI=true
ENV=production
ENABLE_REQUEST_LOGS=false
ENABLE_RESPONSE_LOGS=false
"@
[IO.File]::WriteAllText("$PWD\.env", $envContent.Trim(), $utf8NoBom)

# 4️⃣ 生成 docker-compose.override.yml
Write-Host "⚙️ 生成 docker-compose.override.yml..." -ForegroundColor Yellow
$overrideContent = @'
services:
  ccx:
    ports:
      - "9527:3000"
    environment:
      - PROXY_ACCESS_KEY=${PROXY_ACCESS_KEY}
      - ADMIN_ACCESS_KEY=${ADMIN_ACCESS_KEY}
      - APP_UI_LANGUAGE=${APP_UI_LANGUAGE}
      - LOG_LEVEL=${LOG_LEVEL}
      - ENABLE_WEB_UI=${ENABLE_WEB_UI}
      - ENV=${ENV}
      - ENABLE_REQUEST_LOGS=${ENABLE_REQUEST_LOGS}
      - ENABLE_RESPONSE_LOGS=${ENABLE_RESPONSE_LOGS}
    volumes:
      - ./.config:/app/.config:rw
      - ./logs:/app/logs:rw
      - ./.env:/app/.env:ro
    env_file:
      - ./.env
'@
Set-Content -Path "docker-compose.override.yml" -Value $overrideContent -Encoding UTF8NoBOM -Force

# 5️⃣ 配置 .gitignore
Write-Host "🔐 配置 .gitignore..." -ForegroundColor Yellow
$gitignoreRules = @"

# === Local setup & personal configs (NEVER commit) ===
init.ps1
uninstall.ps1
.env
docker-compose.override.yml
logs/
.config/
*.log
"@
Add-Content -Path ".gitignore" -Value $gitignoreRules -Encoding UTF8NoBOM

# 6️⃣ 输出结果（保持原格式，新增端口提示）
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host "✅ 配置初始化完成！" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host ""
Write-Host "🔑 您的专属访问密钥 (PROXY & ADMIN KEY):" -ForegroundColor Cyan
Write-Host "   $generatedKey" -ForegroundColor White
Write-Host ""
Write-Host "🌐 服务端口已自定义为 9527（非默认 3000）" -ForegroundColor Cyan
Write-Host "   管理面板: http://localhost:9527" -ForegroundColor White
Write-Host "   API 接口: http://localhost:9527/v1" -ForegroundColor White
Write-Host ""
Write-Host "⚠️ 请务必立即复制保存此密钥！" -ForegroundColor Yellow
Write-Host "   后续 API 调用或登录管理面板均需使用。" -ForegroundColor Yellow
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host ""
Write-Host "🚀 下一步：执行 docker compose up -d 启动服务" -ForegroundColor Cyan
Write-Host ""
