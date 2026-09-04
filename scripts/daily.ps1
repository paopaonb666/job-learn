# 每日复习日志：创建 / 编辑 / 提交 / 推送，一条龙
# 用法： .\scripts\daily.ps1
#       .\scripts\daily.ps1 -Message "docs: 补完 Redis 持久化"
#       .\scripts\daily.ps1 -NoPush

param(
    [string]$Message = "",
    [switch]$NoPush
)

$ErrorActionPreference = "Continue"

# 切到仓库根目录
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

# 按日期算路径： daily/2026/09/2026-09-03.md
$now     = Get-Date
$today   = $now.ToString("yyyy-MM-dd")
$year    = $now.ToString("yyyy")
$month   = $now.ToString("MM")
$dir     = Join-Path $repoRoot "daily\$year\$month"
$file    = Join-Path $dir "$today.md"

if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# 文件不存在就先套模板
if (-not (Test-Path $file)) {
    $weekday = @("周日","周一","周二","周三","周四","周五","周六")[[int]$now.DayOfWeek]
    $template = @"
# $today $weekday

## 今天做了什么

-

## 学到了什么

-

## 明天计划

- [ ]

"@
    [System.IO.File]::WriteAllText($file, $template, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "已新建 $file" -ForegroundColor Green
}

# 选一个编辑器打开
$editor = $null
if ($env:EDITOR) {
    $editor = $env:EDITOR
} elseif (Get-Command code -ErrorAction SilentlyContinue) {
    $editor = "code"
} elseif (Get-Command notepad -ErrorAction SilentlyContinue) {
    $editor = "notepad"
}

if ($editor) {
    Write-Host "正在打开编辑器：$editor"
    if ($editor -eq "code") {
        Start-Process -FilePath "code" -ArgumentList @("--wait", $file) -NoNewWindow -Wait
    } else {
        Start-Process -FilePath $editor -ArgumentList $file -Wait
    }
} else {
    Write-Host "没找到编辑器，请手动编辑：$file" -ForegroundColor Yellow
    Read-Host "写完后按回车继续"
}

# 提交
Set-Location $repoRoot
git add -A

$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Host "没有改动，跳过提交。" -ForegroundColor Yellow
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "docs: $today 复习日志"
}

git commit -m $Message
if ($LASTEXITCODE -ne 0) {
    Write-Host "提交失败，已中止。" -ForegroundColor Red
    exit 1
}

if ($NoPush) {
    Write-Host "已提交，按参数跳过推送。"
    exit 0
}

git push origin HEAD
if ($LASTEXITCODE -eq 0) {
    Write-Host "完成：$Message" -ForegroundColor Green
} else {
    Write-Host "推送失败，本地已提交，稍后手动 git push。" -ForegroundColor Yellow
}
