#!/usr/bin/env bash
# debloat-magic-os.sh - 荣耀 MagicOS 安全精简与停用工具
set -e

ACTION="${1:-disable}"

# 绿色安全精简清单（纯信息流、冗余商店、广告营销类）
SAFE_PACKAGES=(
    "com.hihonor.browser"
    "com.hihonor.video"
    "com.hihonor.music"
    "com.hihonor.read"
    "com.hihonor.gamecenter"
    "com.hihonor.vmall"
    "com.hihonor.liveview"
    "com.huawei.skytone"
    "com.hihonor.magichome"
)

function print_usage() {
    echo "用法: $0 [disable|enable|uninstall|restore]"
    echo "  disable   : (推荐) 停用预装软件，随时可在手机或电脑重新启用"
    echo "  enable    : 重新启用之前停用的软件包"
    echo "  uninstall : 从当前用户空间卸载软件包 (保留系统底层分区)"
    echo "  restore   : 重新安装并恢复被卸载的软件包"
    exit 1
}

if ! command -v adb &>/dev/null; then
    echo "[!] 未检测到 adb 命令，请确保已安装。"
    exit 1
fi

echo "=========================================================="
echo "          荣耀手机 MagicOS 自动化安全精简工具             "
echo "=========================================================="
echo "当前执行动作: $ACTION"
echo ""

case "$ACTION" in
    disable)
        echo "[*] 开始批量停用预装应用 (可逆安全模式)..."
        for pkg in "${SAFE_PACKAGES[@]}"; do
            echo -n "正在停用 $pkg ... "
            if adb shell pm disable-user --user 0 "$pkg" 2>/dev/null | grep -q "disabled"; then
                echo "成功"
            else
                echo "已停用或未安装"
            fi
        done
        ;;
    enable)
        echo "[*] 开始批量重新启用预装应用..."
        for pkg in "${SAFE_PACKAGES[@]}"; do
            echo -n "正在启用 $pkg ... "
            adb shell pm enable "$pkg" 2>/dev/null || true
            echo "完成"
        done
        ;;
    uninstall)
        echo "[*] 开始批量用户级卸载预装应用..."
        for pkg in "${SAFE_PACKAGES[@]}"; do
            echo -n "正在卸载 $pkg ... "
            adb shell pm uninstall -k --user 0 "$pkg" 2>/dev/null || true
            echo "完成"
        done
        ;;
    restore)
        echo "[*] 开始批量从底层镜像恢复预装应用..."
        for pkg in "${SAFE_PACKAGES[@]}"; do
            echo -n "正在恢复 $pkg ... "
            adb shell cmd package install-existing "$pkg" 2>/dev/null || true
            echo "完成"
        done
        ;;
    *)
        print_usage
        ;;
esac

echo ""
echo "[✓] 操作全部执行完毕！"
echo "=========================================================="
