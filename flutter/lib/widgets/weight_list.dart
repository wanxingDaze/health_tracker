import 'package:flutter/material.dart';
import '../models/weight_record.dart';
import '../models/user_profile.dart';
import '../models/activity.dart';
import '../theme/app_dimens.dart';
import 'weight_chart.dart';

class WeightListContent extends StatelessWidget {
  final List<WeightRecord> records;
  final double? latestWeight;
  final double? averageWeightLast7Days;
  final ({bool isUp, double diff})? weekOverWeekChange;
  final void Function(WeightRecord) onDelete;
  final UserProfile userProfile;

  const WeightListContent({
    super.key,
    required this.records,
    required this.latestWeight,
    this.averageWeightLast7Days,
    this.weekOverWeekChange,
    required this.onDelete,
    this.userProfile = const UserProfile(),
  });

  @override
  Widget build(BuildContext context) {
    final sortedForChart = List<WeightRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH, vertical: AppDimens.sectionSpacing),
      children: [
        if (records.length >= 2) WeightChart(records: sortedForChart, targetWeight: userProfile.expectedWeightKg),
        if (records.length >= 2) const SizedBox(height: AppDimens.sectionSpacing),
        if (latestWeight != null) ...[
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('当前体重', style: Theme.of(context).textTheme.titleMedium),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${latestWeight!.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (userProfile.hasExpectedWeight) ...[
                            const SizedBox(height: 2),
                            Text(
                              '预期 ${userProfile.expectedWeightKg!.toStringAsFixed(1)} kg · 距预期 ${(latestWeight! - userProfile.expectedWeightKg!).toStringAsFixed(1)} kg',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                          if (userProfile.hasHeight && userProfile.bmi(latestWeight!) != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'BMI ${userProfile.bmi(latestWeight!)!.toStringAsFixed(1)} (${userProfile.bmiCategory(userProfile.bmi(latestWeight!)!)})',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ] else if (!userProfile.hasHeight) ...[
                            const SizedBox(height: 2),
                            Text(
                              '填写身高可查看 BMI',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (averageWeightLast7Days != null || weekOverWeekChange != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (averageWeightLast7Days != null)
                          Expanded(
                            child: _StatBlock(
                              label: '7 日均值',
                              value: userProfile.hasHeight && userProfile.bmi(averageWeightLast7Days!) != null
                                  ? '${averageWeightLast7Days!.toStringAsFixed(1)} kg · BMI ${userProfile.bmi(averageWeightLast7Days!)!.toStringAsFixed(1)}'
                                  : '${averageWeightLast7Days!.toStringAsFixed(1)} kg',
                            ),
                          ),
                        if (averageWeightLast7Days != null && weekOverWeekChange != null) const SizedBox(width: 8),
                        if (weekOverWeekChange != null)
                          Expanded(
                            child: _WeekCompareBlock(change: weekOverWeekChange!),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.sectionSpacing),
        ],
        Text(
          '历史记录',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppDimens.listItemSpacing),
        ...records.map((r) => _WeightItem(record: r, onDelete: () => onDelete(r))),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;

  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDimens.blockRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WeekCompareBlock extends StatelessWidget {
  final ({bool isUp, double diff}) change;

  const _WeekCompareBlock({required this.change});

  @override
  Widget build(BuildContext context) {
    final isUp = change.isUp;
    final diff = change.diff.abs();
    final color = isUp ? Colors.red : Colors.green;
    final arrow = isUp ? Icons.arrow_upward : Icons.arrow_downward;
    final text = isUp ? '上升' : '下降';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDimens.blockRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('较上周', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(arrow, size: 18, color: color),
              const SizedBox(width: 4),
              Text('$text ${diff.toStringAsFixed(1)} kg', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightItem extends StatelessWidget {
  final WeightRecord record;
  final VoidCallback onDelete;

  const _WeightItem({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final activities = record.activities
        .map((id) => Activity.fromId(id))
        .whereType<Activity>()
        .toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
      margin: const EdgeInsets.only(bottom: AppDimens.listItemSpacing),
      child: ListTile(
        title: Row(
          children: [
            Text(record.formattedWeight),
            if (activities.isNotEmpty) ...[
              const SizedBox(width: 8),
              ...activities.map((a) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Tooltip(
                      message: a.label,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(a.icon, size: 18, color: a.color),
                      ),
                    ),
                  )),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (record.note != null && record.note!.isNotEmpty)
              Text(record.note!, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
