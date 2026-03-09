import 'package:flutter/material.dart';

/// 今日活动选项
enum Activity {
  fitness('fitness', '健身', Color(0xFF7B1FA2), Icons.fitness_center),
  basketball('basketball', '篮球', Color(0xFFE65100), Icons.sports_basketball),
  football('football', '足球', Color(0xFF2E7D32), Icons.sports_soccer),
  badminton('badminton', '羽毛球', Color(0xFFFFB300), Icons.sports_tennis),
  swimming('swimming', '游泳', Color(0xFF00838F), Icons.pool),
  running('running', '跑步', Color(0xFFC62828), Icons.directions_run),
  pingpong('pingpong', '乒乓', Color(0xFF1565C0), Icons.sports),
  rest('rest', '休息', Color(0xFF757575), Icons.bed);

  const Activity(this.id, this.label, this.color, this.icon);

  final String id;
  final String label;
  final Color color;
  final IconData icon;

  bool get isRest => this == Activity.rest;

  static Activity? fromId(String id) {
    for (final a in Activity.values) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// 选择活动时的布局：第一行 健身 篮球 足球，第二行 羽毛球 游泳 跑步，第三行 乒乓 休息
  static List<Activity> get selectionOrder => [
        Activity.fitness,
        Activity.basketball,
        Activity.football,
        Activity.badminton,
        Activity.swimming,
        Activity.running,
        Activity.pingpong,
        Activity.rest,
      ];
}
