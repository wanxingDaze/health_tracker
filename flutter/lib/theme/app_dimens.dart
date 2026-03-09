/// 设计规范：统一使用 dp/sp，适配小屏/普通/大屏手机
/// Flutter 中 1 逻辑像素 ≈ Android 1dp
class AppDimens {
  AppDimens._();

  /// 页面左右边距
  static const double pagePaddingH = 16;

  /// 卡片内边距
  static const double cardPadding = 16;

  /// 卡片圆角
  static const double cardRadius = 12;

  /// 小块（StatBlock 等）圆角
  static const double blockRadius = 8;

  /// 按钮最小高度
  static const double buttonMinHeight = 48;

  /// 图表高度（dp），随容器宽度自适应
  static const double chartHeight = 220;

  /// 列表项间距
  static const double listItemSpacing = 8;

  /// 区块间距
  static const double sectionSpacing = 16;
}
