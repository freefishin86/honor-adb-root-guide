# ADB 权限模型与 Linux Root 底层安全机制深度对比

## 1. Android 权限分层金字塔

在深入操作荣耀 MagicOS / EMUI 系统之前，理解 Linux UID 与 Android 安全沙盒至关重要：

| 权限层级 | 运行身份 | UID / GID | 核心特权与操作范围 |
|---|---|---|---|
| **Root (超级用户)** | `root` | `0:0` | 无限制读写所有块设备、挂载只读分区 (`/system`, `/vendor`)、注入内核模块、篡改系统二进制 |
| **System (系统服务)** | `system` | `1000` | 运行 Android Framework 核心服务（ActivityManager, PackageManager 等），操作核心系统设置 |
| **ADB Shell** | `shell` | `2000` | 可读写外部存储、调用 `pm`、`am`、`cmd` 内部指令、修改 `settings global/secure`、启动调试服务 |
| **普通 App** | `u0_aXXX` | `10000+` | 受到完整应用沙盒隔离，仅能通过 Binder 机制申请受限的 Android 运行时权限 |

---

## 2. 为什么 `adb root` 在商用荣耀手机上必定失败？

### 2.1 adbd 守护进程逻辑
当你在电脑端输入 `adb root` 时，电脑客户端会向手机上的 `adbd`（ADB 守护进程）发送重启请求。
`adbd` 在源码（`packages/modules/adb/daemon/main.cpp`）中的核心逻辑如下：

```c
if (!should_drop_privileges()) {
    // 允许切换到 root
} else {
    if (drop_privileges(0) != 0) {
        printf("adbd cannot run as root in production builds\n");
        exit(1);
    }
}
```

其中 `should_drop_privileges()` 判断两个核心系统属性：
- `ro.debuggable`（是否允许调试系统进程）
- `ro.secure`（是否启用安全降权）

商用荣耀手机的编译参数必然是：
- `ro.debuggable=0`
- `ro.secure=1`
- `ro.build.type=user`

因此 `adbd` 启动后会通过 Linux 原生系统调用 `setuid(AID_SHELL)` 和 `setgid(AID_SHELL)`，强制将自身身份固定为 `shell (UID 2000)`，杜绝外部任意提权。

### 2.2 SELinux Enforcing 限制
即使存在利用内核提权漏洞临时修改了 UID 为 0，Android 强制开启的 SELinux 策略依然定义了严格的 `domain` 规则。
`shell` 域被严禁向 `system_file`、`kernel`、`device` 等安全敏感类型进行直接操作。任何越界访问均会被内核直接丢弃并记录 `avc: denied`。

---

## 3. 荣耀手机的现代安全防线：AVB 2.0 与硬件 Knox/TEE 级防护

荣耀 MagicOS 具备深度的软硬件协同安全架构：
1. **AVB 2.0 (Android Verified Boot)**：从 BootROM -> XBL -> ABL -> Boot -> System 构成严密的硬件可信根信任链。任何未经过荣耀官方私钥签名的镜像均会被硬件拒绝加载。
2. **EROFS 只读文件系统与 dm-verity**：系统分区以不可写入的 EROFS 格式固化，扇区哈希表实时比对，杜绝向 `/system` 塞入 `su` 二进制。
3. **TEE 隔离与信托**：生物识别、支付证书、设备完整性由独立安全芯片守护。

---

## 4. 结论：拒绝伪需求，拥抱「免 Root 极致掌控」

对于日常使用荣耀手机而言，追求完整 Root 往往弊大于利（失去银行 App 兼容性、失去 OTA 系统推送、严重破坏电池管理）。
掌握 ADB Shell (UID 2000) 提供的免 Root 工具链，才是最大化发挥荣耀硬件潜能的科学最优解。
