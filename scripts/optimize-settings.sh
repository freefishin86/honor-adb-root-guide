#!/usr/bin/env bash
# optimize-settings.sh - 荣耀 MagicOS 性能调优与动画加速工具
set -e

echo "=========================================================="
echo "          荣耀手机 MagicOS 系统动画与全局调优工具          "
echo "=========================================================="

if ! command -v adb &>/dev/null; then
    echo "[!] 未检测到 adb 命令，请确保已安装。"
    exit 1
fi

echo "[*] 正在优化窗口与过渡动画缩放 (加速日常操作视觉流程度)..."
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb shell settings put global animator_duration_scale 0.5
echo "[✓] 动画缩放倍率已调整为 0.5x (大幅提升开合 App 敏捷度)"

echo ""
echo "[*] 优化后台日志与调试负载..."
# 关闭可能残留的低效网络日志
adb shell settings put global mobile_data_always_on 0
echo "[✓] 基础网络与动画设置已优化完毕！"
echo "=========================================================="
