import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_record.dart';
import '../models/activity.dart';

class WeightRepository extends ChangeNotifier {
  void _safeNotify() {
    SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }
  static const _key = 'weight_records';

  List<WeightRecord> _records = [];
  List<WeightRecord> get records => List.unmodifiable(_records);
  double? get latestWeight => _records.isNotEmpty ? _records.first.weight : null;

  /// 最近 7 天内记录的体重平均值（以最新记录日期为基准，含当天共 7 天）
  double? get averageWeightLast7Days {
    if (_records.isEmpty) return null;
    final latestDate = _records.first.date;
    final cutoff = latestDate.subtract(const Duration(days: 6));
    final inRange = _records.where((r) => !r.date.isBefore(cutoff)).toList();
    if (inRange.isEmpty) return null;
    final sum = inRange.map((r) => r.weight).reduce((a, b) => a + b);
    return sum / inRange.length;
  }

  /// 本周较上周的 7 日均值变化：(是否上升, 差值 kg)，null 表示数据不足
  ({bool isUp, double diff})? get weekOverWeekChange {
    if (_records.isEmpty) return null;
    final sorted = List<WeightRecord>.from(_records)..sort((a, b) => a.date.compareTo(b.date));
    final latest = sorted.last.date;

    final thisWeekEnd = latest;
    final thisWeekStart = thisWeekEnd.subtract(const Duration(days: 6));
    final thisWeek = sorted.where((r) => !r.date.isBefore(thisWeekStart) && !r.date.isAfter(thisWeekEnd)).toList();
    if (thisWeek.isEmpty) return null;

    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
    final lastWeekStart = lastWeekEnd.subtract(const Duration(days: 6));
    final lastWeek = sorted.where((r) => !r.date.isBefore(lastWeekStart) && !r.date.isAfter(lastWeekEnd)).toList();
    if (lastWeek.isEmpty) return null;

    final thisAvg = thisWeek.map((r) => r.weight).reduce((a, b) => a + b) / thisWeek.length;
    final lastAvg = lastWeek.map((r) => r.weight).reduce((a, b) => a + b) / lastWeek.length;
    final diff = thisAvg - lastAvg;
    return (isUp: diff > 0, diff: diff);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _records = list
            .map((e) => WeightRecord.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } catch (_) {}
    }
    _safeNotify();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _records.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<void> add(WeightRecord record) async {
    _records.insert(0, record);
    await _save();
    _safeNotify();
  }

  Future<void> delete(WeightRecord record) async {
    _records.removeWhere((e) => e.id == record.id);
    await _save();
    _safeNotify();
  }

  Future<void> deleteBatch(List<WeightRecord> toDelete) async {
    final ids = toDelete.map((r) => r.id).toSet();
    _records.removeWhere((e) => ids.contains(e.id));
    await _save();
    _safeNotify();
  }

  /// 加载指定天数的模拟体重数据（用于测试图表）
  Future<void> loadSimulatedData(int days) async {
    final random = Random(42);
    final now = DateTime.now();
    final baseWeight = 68.0;
    double weight = baseWeight;

    final sportsOnly = Activity.values.where((a) => !a.isRest).toList();

    _records = List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - 1 - i));
      weight += (random.nextDouble() - 0.5) * 0.8;
      weight = weight.clamp(62.0, 76.0);

      final List<String> activities;
      final r = random.nextDouble();
      if (r < 0.12) {
        activities = [];
      } else if (r < 0.25) {
        activities = [Activity.rest.id];
      } else {
        final count = 1 + (random.nextInt(3));
        final picked = <Activity>{};
        while (picked.length < count) {
          picked.add(sportsOnly[random.nextInt(sportsOnly.length)]);
        }
        activities = picked.map((a) => a.id).toList();
      }

      return WeightRecord(
        id: 'sim_$i',
        weight: double.parse(weight.toStringAsFixed(1)),
        date: DateTime(date.year, date.month, date.day, 8 + (i % 3), (i * 7) % 60),
        activities: activities,
      );
    })
      ..sort((a, b) => b.date.compareTo(a.date));
    await _save();
    _safeNotify();
  }
}
