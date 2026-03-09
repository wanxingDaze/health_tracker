# HealthTracker - 体重记录

跨平台体重记录应用：iOS (SwiftUI) + Android (Jetpack Compose)。

## 功能

- **添加体重**：记录体重（kg）、日期时间和备注
- **历史列表**：按时间倒序查看所有记录
- **当前体重**：展示最新一次记录
- **删除记录**：iOS 左滑删除 / Android 点击删除按钮
- **体重趋势图**：折线图展示体重变化
- **数据持久化**：iOS UserDefaults / Android SharedPreferences

## 文档

- [CHANGELOG.md](CHANGELOG.md) - 需求与修改记录

---

## iOS 版本

1. 用 **Xcode** 打开 `HealthTracker.xcodeproj`
2. 选择模拟器或真机
3. 点击 Run (⌘R)

**系统要求**：iOS 17.0+ / Xcode 15+ / Swift 5.9+

---

## Android 版本

1. 用 **Android Studio** 打开 `android/` 目录
2. 等待 Gradle 同步完成
3. 选择模拟器或真机，点击 Run (▶)

**系统要求**：Android 7.0+ (API 24) / Android Studio Hedgehog+

**项目结构**：
```
android/
├── app/src/main/java/com/wanxx/healthtracker/
└── build.gradle.kts
```

---

## Flutter Android 版（子项目）

`flutter/` 为仅面向 Android 的 Flutter 子项目，与原生 Android 版功能一致。

```bash
cd flutter
flutter pub get
flutter run
```

详见 [flutter/README.md](flutter/README.md)

---

## 项目结构

```
health_tracker/
├── HealthTracker.xcodeproj   # iOS 项目
├── HealthTracker/            # iOS 源码
├── android/                  # Android 原生 (Kotlin + Compose)
├── flutter/                  # Android Flutter 子项目
├── CHANGELOG.md
└── README.md
```

## License

MIT
