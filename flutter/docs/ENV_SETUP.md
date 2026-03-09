# 环境变量配置说明（Android + 鸿蒙共同开发）

## 当前配置

| 变量 | 值 |
|------|-----|
| `PATH` 最前 | `E:\flutter_flutter\bin`（鸿蒙版 Flutter） |
| `DEVECO_SDK_HOME` | `E:\DevEco Studio\sdk` |
| `TOOL_HOME` | `E:\DevEco Studio` |
| `PUB_HOSTED_URL` | `https://mirrors.tuna.tsinghua.edu.cn/dart-pub` |
| `FLUTTER_STORAGE_BASE_URL` | `https://mirrors.tuna.tsinghua.edu.cn/flutter` |

## Android 和鸿蒙可以共同开发吗？

**可以。** 鸿蒙版 Flutter（`flutter_flutter`）是 Flutter 的 fork，在保留 Android 支持的基础上增加了鸿蒙（ohos）支持。

使用同一套 Flutter SDK 和同一项目即可同时开发 Android 与鸿蒙：

```powershell
# 添加双平台支持
flutter create --platforms android,ohos .

# 运行到 Android 设备
flutter run -d <android-device-id>

# 运行到鸿蒙设备
flutter run -d <harmony-device-id>

# 编译
flutter build apk        # Android
flutter build hap        # 鸿蒙 HAP
```

## 切换回官方 Flutter（仅 Android）

若暂时只做 Android 且想用官方 Flutter，可将 PATH 中两个 Flutter 顺序对调：

- **官方 Flutter**：`E:\flutter_windows_3.41.4-stable\flutter\bin`
- **鸿蒙版 Flutter**：`E:\flutter_flutter\bin`

或在终端临时切换：

```powershell
# 临时使用官方 Flutter
$env:Path = "E:\flutter_windows_3.41.4-stable\flutter\bin;" + $env:Path
```

## 生效方式

修改环境变量后需**重启终端或 Cursor** 才能生效。
