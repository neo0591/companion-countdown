#!/usr/bin/env bash
# 一键生成 Xcode 工程（macOS 上执行）
set -e
command -v xcodegen >/dev/null 2>&1 || { echo "需要先安装 xcodegen: brew install xcodegen"; exit 1; }
cd "$(dirname "$0")/.."
xcodegen generate
echo "✅ 已生成 companion-countdown.xcodeproj，用 open companion-countdown.xcodeproj 打开"
