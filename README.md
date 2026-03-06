# HealthTracker - 体重记录

iOS 体重记录应用，使用 SwiftUI 构建。

## 功能

- **添加体重**：记录体重（kg）、日期时间和备注
- **历史列表**：按时间倒序查看所有记录
- **当前体重**：展示最新一次记录
- **左滑删除**：删除单条记录
- **体重趋势图**：折线图展示体重变化
- **数据持久化**：使用 UserDefaults 本地存储

## 文档

- [CHANGELOG.md](CHANGELOG.md) - 需求与修改记录

## 运行

1. 用 **Xcode** 打开 `HealthTracker.xcodeproj`
2. 选择模拟器或真机
3. 点击 Run (⌘R)

## 系统要求

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## 项目结构

```
HealthTracker/
├── HealthTrackerApp.swift    # App 入口
├── Models/
│   └── WeightRecord.swift   # 体重数据模型
├── Views/
│   ├── ContentView.swift     # 主界面
│   ├── WeightListView.swift  # 记录列表
│   ├── WeightChartView.swift # 体重趋势图
│   └── AddWeightView.swift   # 添加记录
├── Services/
│   └── WeightStore.swift    # 数据持久化
└── Assets.xcassets           # 资源
```

## License

MIT
