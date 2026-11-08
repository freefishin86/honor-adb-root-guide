#!/usr/bin/env bash
# check-device.sh - 荣耀设备连通性与底层环境自检脚本
set -e

echo "=========================================================="
echo "      荣耀手机 (MagicOS) ADB 环境自检与属性探测工具      "
echo "=========================================================="

# 1. 检查本地 ADB 命令
if ! command -v adb &>/dev/null; then
    echo "[!] 错误: 未在系统路径中找到 adb 工具，请先安装 android-tools 或平台工具包。"
    exit 1
fi

# 2. 检查设备连接
echo "[*] 正在探测 USB/无线连接设备..."
DEVICES=$(adb devices | grep -v "List" | grep "device$" || true)

if [ -z "$DEVICES" ]; then
    echo "[!] 未检测到已授权的设备！"
    echo "    请排查以下事项:"
    echo "    1. 手机是否已用数据线连接电脑并开启【USB调试】；"
    echo "    2. 手机屏幕是否弹出【允许USB调试】提示并点击确定；"
    echo "    3. 是否需要切换为【传输文件(MTP)】模式以激活端口。"
    exit 1
fi

DEVICE_COUNT=$(echo "$DEVICES" | wc -l)
echo "[+] 成功检测到 $DEVICE_COUNT 台在线设备。"

# 3. 提取关键系统参数
MODEL=$(adb shell getprop ro.product.model 2>/dev/null || echo "Unknown")
BRAND=$(adb shell getprop ro.product.brand 2>/dev/null || echo "Unknown")
MANUFACTURER=$(adb shell getprop ro.product.manufacturer 2>/dev/null || echo "Unknown")
OS_VERSION=$(adb shell getprop ro.build.version.release 2>/dev/null || echo "Unknown")
HONOR_OS=$(adb shell getprop ro.build.version.magic 2>/dev/null || adb shell getprop ro.build.version.emui 2>/dev/null || echo "Unknown")
BUILD_TYPE=$(adb shell getprop ro.build.type 2>/dev/null || echo "user")
SECURE=$(adb shell getprop ro.secure 2>/dev/null || echo "1")
DEBUGGABLE=$(adb shell getprop ro.debuggable 2>/dev/null || echo "0")
SELINUX=$(adb shell getenforce 2>/dev/null || echo "Enforcing")

echo ""
echo "--- 硬件与系统信息 ---"
echo "设备品牌: $BRAND"
echo "制造厂商: $MANUFACTURER"
echo "设备型号: $MODEL"
echo "Android 版本: $OS_VERSION"
echo "系统固件版本: $HONOR_OS"

echo ""
echo "--- 安全与权限状态 ---"
echo "编译类型 (ro.build.type): $BUILD_TYPE"
echo "安全锁定 (ro.secure): $SECURE"
echo "可调试态 (ro.debuggable): $DEBUGGABLE"
echo "SELinux 状态: $SELINUX"

echo ""
if [ "$BUILD_TYPE" == "user" ] && [ "$SECURE" == "1" ]; then
    echo "[i] 鉴定结果: 当前固件为商用生产版本 (User Build)。"
    echo "    硬件安全链完整，无法通过 adb root 提权至 UID 0。"
    echo "    建议遵循本指南，使用 ADB Shell 用户空间停用与 Shizuku 开展免 Root 调优。"
fi
echo "=========================================================="
