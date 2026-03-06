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

## 后续可扩展

- 编辑体重记录
- 导出为 CSV / 备份
- 与 HealthKit 同步
- 目标体重设置与进度展示
