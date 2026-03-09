# 开发日志 - 需求与修改记录

本文档记录 HealthTracker 项目每次需求与对应的代码修改。

---

## 需求一：在 iOS 界面实现体重记录

**需求描述**：在 health_tracker 项目中实现功能，在 iOS 界面实行一个体重记录。

**修改内容**：

### 1. 新建项目结构

- `HealthTracker/HealthTrackerApp.swift` - App 入口，注入 WeightStore
- `HealthTracker/Models/WeightRecord.swift` - 体重数据模型（id、weight、date、note）
- `HealthTracker/Services/WeightStore.swift` - 数据持久化（UserDefaults）
- `HealthTracker/Views/ContentView.swift` - 主界面，导航与添加按钮
- `HealthTracker/Views/WeightListView.swift` - 体重记录列表
- `HealthTracker/Views/AddWeightView.swift` - 添加体重表单
- `HealthTracker/Assets.xcassets` - 资源目录
- `HealthTracker.xcodeproj` - Xcode 项目配置

### 2. 实现功能

| 功能 | 说明 |
|------|------|
| 添加记录 | 输入体重(kg)、日期时间、备注 |
| 当前体重 | 列表顶部展示最新记录 |
| 历史列表 | 按时间倒序展示，左滑删除 |
| 持久化 | UserDefaults 本地存储 |

### 3. 新增文件清单

```
HealthTrackerApp.swift
Models/WeightRecord.swift
Views/ContentView.swift
Views/WeightListView.swift
Views/AddWeightView.swift
Services/WeightStore.swift
Assets.xcassets/
```

---

## 需求二：体重数据可视化

**需求描述**：我怎么可视化（体重数据）。

**修改内容**：

### 1. 新增图表视图

- `HealthTracker/Views/WeightChartView.swift` - 体重趋势折线图
  - 使用 Swift Charts 框架
  - X 轴：日期
  - Y 轴：体重 (kg)
  - 折线 + 数据点，曲线平滑 (catmullRom)
  - 无数据时显示占位提示

### 2. 集成到主界面

- 修改 `WeightListView.swift`：在「当前体重」上方插入 `WeightChartView` 作为列表第一项
- 图表区域使用圆角卡片样式，背景色 `secondarySystemBackground`

### 3. 更新 Xcode 项目

- 在 `project.pbxproj` 中注册 `WeightChartView.swift`

### 4. 修改文件清单

| 修改类型 | 文件 |
|----------|------|
| 新增 | `Views/WeightChartView.swift` |
| 修改 | `Views/WeightListView.swift` |
| 修改 | `HealthTracker.xcodeproj/project.pbxproj` |

---

## 需求三：拓展到 Android 平台

**需求描述**：把项目拓展到安卓领域，在 health_tracker 另起一个安卓版本。

**修改内容**：

### 1. 新建 Android 项目

- `android/` - Android 项目根目录
- `android/settings.gradle.kts` - 项目配置
- `android/build.gradle.kts` - 根构建脚本
- `android/app/build.gradle.kts` - 应用模块
- Kotlin 1.9 + Jetpack Compose + Material 3

### 2. 实现功能（与 iOS 对齐）

| 功能 | 实现 |
|------|------|
| 添加记录 | AddWeightDialog 弹窗 |
| 当前体重 | 卡片展示 |
| 历史列表 | LazyColumn + 删除按钮 |
| 体重趋势图 | Canvas 自绘折线图 |
| 持久化 | SharedPreferences + Gson |

### 3. 新增文件清单

```
android/
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
├── gradle/wrapper/gradle-wrapper.properties
├── app/
│   ├── build.gradle.kts
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/wanxx/healthtracker/
│       │   ├── MainActivity.kt
│       │   ├── data/WeightRecord.kt
│       │   ├── data/WeightRepository.kt
│       │   └── ui/
│       │       ├── WeightViewModel.kt
│       │       ├── MainScreen.kt
│       │       ├── WeightListContent.kt
│       │       ├── AddWeightDialog.kt
│       │       └── WeightChart.kt
│       └── res/
│           ├── values/strings.xml, themes.xml, colors.xml
│           └── drawable/ic_launcher.xml
```

### 4. 修改文件

- `README.md` - 增加 Android 运行说明与双平台项目结构

---

## 需求四：Flutter Android 子项目

**需求描述**：在 health_tracker 下创建一个 Flutter 子项目，单独服务于安卓版本，不必共用 iOS 和安卓。

**修改内容**：

### 1. 新建 Flutter 项目

- `flutter/` - 仅包含 Android 平台的 Flutter 子项目
- 不包含 ios、web 等平台目录

### 2. 实现功能（与 Android 原生版对齐）

| 功能 | 实现 |
|------|------|
| 添加记录 | AddWeightDialog 弹窗 |
| 当前体重 | 卡片展示 |
| 历史列表 | ListView + 删除按钮 |
| 体重趋势图 | fl_chart 折线图 |
| 持久化 | SharedPreferences |

### 3. 新增文件清单

```
flutter/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── models/weight_record.dart
│   ├── services/weight_repository.dart
│   ├── screens/main_screen.dart
│   └── widgets/
│       ├── weight_chart.dart
│       ├── weight_list.dart
│       └── add_weight_dialog.dart
├── android/          # 仅 Android 平台
└── README.md
```

### 4. 依赖

- `shared_preferences` - 本地存储
- `fl_chart` - 折线图

---

## 需求五：鸿蒙 (HarmonyOS) 适配

**需求描述**：在相同时适配鸿蒙，用户已安装 DevEco Studio 于 E:\DevEco Studio\bin。

**修改内容**：

### 1. 新增文档

- `flutter/docs/HARMONYOS_SETUP.md` - 鸿蒙环境搭建与适配指南

### 2. 环境变量

- `DEVECO_SDK_HOME` = `E:\DevEco Studio\sdk`
- `TOOL_HOME` = `E:\DevEco Studio`

### 3. 重要说明

鸿蒙适配需使用 **OpenHarmony 版 Flutter SDK**（Gitee: OpenHarmony-SIG/flutter_flutter），与官方 Flutter 不同。需按文档克隆并配置后再执行 `flutter create --platforms ohos .`。

---

## 后续可扩展

- 编辑体重记录
- 导出为 CSV / 备份
- iOS：与 HealthKit 同步
- Android：与 Google Fit 同步
- 目标体重设置与进度展示
