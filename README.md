# 荣耀手机 (MagicOS / EMUI) ADB 与 Root 权威技术指南

本项目是针对荣耀 (Honor) 智能手机的底层权限剖析、ADB 调试提权实战、系统深度精简与免 Root 性能调优的开源工程指南。旨在为开发者、极客及高级用户提供可验证、防变砖、零玄学的工程化参考。

---

## 核心认知与技术真相辟谣

在折腾荣耀手机权限前，必须建立清晰的第一性原理认知：

1. **量产版荣耀手机无法仅通过 ADB 命令获得完整 Root 权限 (UID 0)**
   - Android 系统设计中，`adb root` 仅在 `userdebug` 或 `eng` 编译类型的固件中生效。
   - 荣耀出厂商用固件均为 `user` 构建，只读系统属性 `ro.secure=1`，`ro.debuggable=0`，SELinux 处于强制执行模式 (`Enforcing`)。
   - 即使通过 USB 连接执行 `adb root`，守护进程只会返回 `adbd cannot run as root in production builds`。

2. **Bootloader 官方闭锁现状**
   - 华为与荣耀自 2018 年起全面停止提供官方 Bootloader 解锁码服务。
   - 在未解锁 Bootloader 的前提下，Android Verified Boot (AVB 2.0) 与 dm-verity 机制会校验 `boot`、`init_boot` 及 `system` 分区的 RSA 签名。任何私自篡改内核镜像（刷入 Magisk / KernelSU / APatch）均会导致设备无法通过安全校验，直接卡死在 Fastboot Rescue 界面。
   - 市场上任何宣称「免解 BL 锁、纯靠一条 ADB 指令一键永久 Root 荣耀新机」的软件，均为捆绑流氓推广、偷换概念（将 Shizuku/ADB Shell 权限偷换为 Root）的虚假骗局。

3. **ADB 的真正战略价值：免 Root 终极提权方案**
   - ADB Shell 默认运行在 `shell` 用户空间 (`UID 2000`)。
   - 该权限级别高于普通第三方 App (`UID 10000+`)，享有修改全局安全设置 (`WRITE_SECURE_SETTINGS`)、无视系统限制停用或卸载用户空间预装软件、通过 Shizuku 桥接系统级 API 等核心特权。
   - 95% 以上的「Root 刚需」（去广告、卸载自带全家桶、冻结后台顽固进程、修改高刷参数）均可通过 ADB 与 Shizuku 完美达成，无需承担变砖与失去保修的风险。

---

## 工程目录结构

```
honor-adb-root-guide/
├── README.md                     # 本指南总纲与核心认知
├── docs/                         # 专题技术文档
│   ├── 01-adb-vs-root.md         # ADB 权限模型 vs Linux Root 底层安全机制深度对比
│   ├── 02-debloat-package-list.md# MagicOS 全机型预装包分级精简对照表 (安全/谨慎/红线)
│   └── 03-shizuku-guide.md       # Shizuku + 无线调试免电脑常驻实战教程
└── scripts/                      # 自动化可执行脚本
    ├── check-device.sh           # 荣耀设备环境自检与属性探测工具
    ├── debloat-magic-os.sh       # 模块化批量精简与自愈恢复脚本
    └── optimize-settings.sh      # 系统动画加速与后台激进优化脚本
```

---

## 快速上手与环境准备

### 1. 开启荣耀手机开发者模式与 ADB 权限
1. 打开手机「设置」->「关于手机」。
2. 连续点击「版本号」7 次，直到屏幕提示「您正处于开发者模式」。
3. 返回「设置」->「系统和更新」->「开发人员选项」。
4. 打开「USB 调试」开关。
5. **关键步骤**：部分 MagicOS 机型需同时打开「仅充电模式下允许 ADB 调试」以及「通过 USB 验证应用」。
6. 用数据线将手机连接至电脑，手机端勾选「始终允许此计算机进行调试」并点击确定。

### 2. 验证设备连接
运行自检脚本：
```bash
chmod +x scripts/check-device.sh
./scripts/check-device.sh
```

---

## 安全免责声明

本项目提供的脚本与命令均经过严格边界测试，但深入系统底层操作仍存在不可预估风险：
- 请在操作前备份手机重要数据。
- 严禁随意冻结或卸载标记为「红线级」的核心框架包。
- 本项目对因操作不当引起的系统异常、数据丢失或保修争议不承担连带责任。
