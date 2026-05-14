# uninstall.ps1 - CCX 项目彻底卸载脚本
# ⚠️ 警告：此操作不可逆，将删除所有数据和配置！

param([switch]$KeepData)

Write-Host "🛑 开始卸载 CCX 项目..." -ForegroundColor Red

if (-not $KeepData) {
    $confirm = Read-Host "⚠️  这将删除所有配置和数据 (.env, .config, logs)。确定继续吗？(yes/no)"
    if ($confirm -ne "yes") {
        Write-Host "❌ 操作已取消" -ForegroundColor Yellow
        exit
    }
}

# 1. 停止并删除容器/网络
Write-Host "📦 停止并删除容器..." -ForegroundColor Cyan
docker compose down

# 2. 删除本地持久化数据（如果未选择保留）
if (-not $KeepData) {
    Write-Host "🗑️  删除本地配置和数据..." -ForegroundColor Cyan
    Remove-Item -Path ".config", "logs", ".env", "docker-compose.override.yml" -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. 删除镜像
Write-Host "🖼️  删除镜像..." -ForegroundColor Cyan
docker rmi crpi-i19l8zl0ugidq97v.cn-hangzhou.personal.cr.aliyuncs.com/bene/ccx:latest -ErrorAction SilentlyContinue

# 4. 清理系统残留
Write-Host "🧹 清理 Docker 系统残留..." -ForegroundColor Cyan
docker system prune -f

Write-Host "✅ 卸载完成！" -ForegroundColor Green