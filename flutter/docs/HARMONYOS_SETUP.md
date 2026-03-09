# 鸿蒙 (HarmonyOS) 适配指南

## 重要说明

Flutter 适配鸿蒙需使用 **OpenHarmony 版 Flutter SDK**（`E:\flutter_flutter`），与官方 Flutter SDK 不同。鸿蒙版 Flutter **同时支持 Android 和鸿蒙**，可在一个项目中共同开发双平台。

## 一、环境准备

### 1. 安装 OpenHarmony 版 Flutter SDK

```powershell
# 克隆鸿蒙版 Flutter（建议放在 E 盘）
cd E:\
git clone https://gitee.com/openharmony-sig/flutter_flutter.git
cd flutter_flutter
git checkout -b dev origin/dev
```

### 2. 配置环境变量（Windows）

在 **系统环境变量** 或 **用户环境变量** 中添加：

| 变量名 | 值 |
|--------|-----|
| `PATH` | 在**最前面**添加 `E:\flutter_flutter\bin` |
| `DEVECO_SDK_HOME` | `E:\DevEco Studio\sdk`（DevEco 的 SDK 目录） |
| `TOOL_HOME` | `E:\DevEco Studio` |
| `PUB_HOSTED_URL` | `https://mirrors.tuna.tsinghua.edu.cn/dart-pub` |
| `FLUTTER_STORAGE_BASE_URL` | `https://mirrors.tuna.tsinghua.edu.cn/flutter` |

> 若 DevEco Studio 的 SDK 在其他路径，可在 DevEco 中查看：File → Settings → SDK

### 3. 安装 JDK 17

鸿蒙开发需 JDK 17，可从 [Oracle](https://www.oracle.com/java/technologies/downloads/#java17) 或 [Adoptium](https://adoptium.net/) 下载。

### 4. 在 DevEco Studio 中安装模拟器

打开 DevEco Studio → Tools → Device Manager → 创建并下载模拟器。

---

## 二、为项目添加鸿蒙平台

完成上述环境配置后，**关闭当前终端，重新打开**，然后执行：

```powershell
cd E:\projects\health_tracker\flutter

# 使用鸿蒙版 Flutter（确保 PATH 中 E:\flutter_flutter\bin 优先）
flutter create --platforms ohos .
```

成功后会在项目下生成 `ohos/` 目录。

---

## 三、编译与运行

```powershell
# 编译 HAP 包
flutter build hap --debug

# 运行到设备/模拟器
flutter run -d <deviceId>
```

或在 **DevEco Studio** 中打开 `ohos/` 目录，选择设备后点击运行。

---

## 四、依赖兼容性

| 依赖 | 鸿蒙兼容性 |
|------|------------|
| `shared_preferences` | ⚠️ 需验证，可能需鸿蒙适配 |
| `fl_chart` | ✅ 纯 Dart，一般兼容 |

若运行时报错，可查阅 [OpenHarmony-SIG/flutter_samples](https://gitee.com/openharmony-sig/flutter_samples) 的适配示例。
