# 体重记录 - Android 版（Flutter）

仅面向 Android 的 Flutter 子项目，与 `android/` 原生 Kotlin 版本功能一致。

## 功能

- 添加体重记录（体重、备注）
- 当前体重展示
- 历史记录列表，删除单条
- 体重趋势折线图（fl_chart）
- SharedPreferences 持久化

## 运行

**前置**：需安装 [Flutter SDK](https://flutter.dev/docs/get-started/install) 并配置环境变量。

```bash
cd health_tracker/flutter
flutter pub get
flutter run
```

仅构建 Android：

```bash
flutter build apk
# 或
flutter run -d android
```

## 项目结构

```
flutter/
├── lib/
│   ├── main.dart
│   ├── models/weight_record.dart
│   ├── services/weight_repository.dart
│   ├── screens/main_screen.dart
│   └── widgets/
│       ├── weight_chart.dart    # fl_chart 折线图
│       ├── weight_list.dart
│       └── add_weight_dialog.dart
├── android/          # 仅 Android 平台
├── pubspec.yaml
└── README.md
```

## 鸿蒙适配

需使用 **OpenHarmony 版 Flutter SDK**，详见 [docs/HARMONYOS_SETUP.md](docs/HARMONYOS_SETUP.md)。

## 依赖

- `shared_preferences` - 本地存储
- `fl_chart` - 折线图
