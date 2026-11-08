# 荣耀 MagicOS 预装应用安全精简与分级白皮书

本文档整理了荣耀手机（MagicOS 7.0 / 8.0 / 9.0 及旧款 EMUI）中自带软件包的包名、功能定义、精简建议与安全分级。

---

## 精简核心原理与安全边界

使用 ADB 精简自带软件时，推荐使用用户空间停用或用户级卸载，**切勿使用破坏性物理删除**：

- **推荐方案（停用应用，随时可逆恢复）**：
  ```bash
  adb shell pm disable-user --user 0 <包名>
  ```
  恢复命令：
  ```bash
  adb shell pm enable <包名>
  ```

- **备用方案（用户级卸载，不影响底层系统分区）**：
  ```bash
  adb shell pm uninstall -k --user 0 <包名>
  ```
  恢复命令：
  ```bash
  adb shell cmd package install-existing <包名>
  ```

---

## 预装软件包分级清单

### 一、 绿色级：极力推荐精简（无副作用、广告大户、纯营销预装）

| 包名 | 应用名称 | 卸载影响 |
|---|---|---|
| `com.hihonor.browser` | 荣耀浏览器 | 无影响，建议替换为 Chrome / Edge / Via |
| `com.hihonor.video` | 荣耀视频 | 无影响，内置大量信息流与推广 |
| `com.hihonor.music` | 荣耀音乐 | 无影响，内置各类商业推广内容 |
| `com.hihonor.read` | 荣耀阅读 | 无影响，网络小说推广 |
| `com.hihonor.gamecenter` | 游戏中心 | 卸载后不影响游戏本体运行，消除弹窗 |
| `com.hihonor.appmarket` | 应用市场 | 若习惯使用开源应用商店或微信直接更新可精简 |
| `com.hihonor.wallet` | 荣耀钱包 | 不用手机刷公交门禁卡时可精简 |
| `com.hihonor.vmall` | 荣耀商城 | 纯电商购物软件 |
| `com.hihonor.liveview` | 灵动胶囊服务 | 喜欢极简屏幕界面的用户可停用 |
| `com.huawei.skytone` | 天际通 / 境外流量 | 国内无出境漫游需求可安全停用 |
| `com.hihonor.magichome` | 智慧空间 | 智能家居控制，无相关生态硬件可精简 |

---

### 二、 黄色级：谨慎精简（特定功能受限，按需取舍）

| 包名 | 应用名称 | 卸载副作用说明 |
|---|---|---|
| `com.hihonor.yoyo` | YOYO 建议 / 语音助手 | 停用后负一屏卡片、全局语音唤醒、智慧识屏失效 |
| `com.hihonor.trustagent` | 荣耀智慧互联 | 停用后与荣耀笔记本、平板的多屏协同与跨设备剪贴板失效 |
| `com.hihonor.cloud` | 荣耀云空间 | 停用后云相册同步、联系人与备忘录自动备份失效 |
| `com.hihonor.health` | 荣耀运动健康 | 停用后无法同步智能手环/手表步数与健康体征 |
| `com.hihonor.android.totemweather` | 天气 | 桌面天气小部件不更新，可替换第三方纯净天气 |

---

### 三、 红色禁区：绝对严禁冻结/卸载（冻结必卡开机动画或无限重启）

| 包名 | 系统核心职责 | 违规操作后果 |
|---|---|---|
| `android` | Android 核心操作系统框架 | 瞬间黑屏崩溃，手机变砖 |
| `com.android.systemui` | 系统界面服务 (状态栏/导航栏/锁屏) | 无法亮屏进入桌面，无限报错 |
| `com.hihonor.android.launcher` | 荣耀系统桌面 (Launcher) | **未提前安装并设为默认第三方桌面时，开机黑屏无桌面** |
| `com.android.phone` | 电话与基带通信核心服务 | 手机无法读 SIM 卡、无法拨打电话、射频死锁 |
| `com.android.settings` | 系统设置与全局参数配置 | 系统设置崩溃闪退，各种底层服务失联 |
| `com.android.providers.telephony` | 电话短信底层数据提供者 | 无法接收任何短信验证码 |
| `com.hihonor.securityadd` | 荣耀安全守门员与设备密钥库 | 导致指纹解锁失效、开机身份校验卡死 |
