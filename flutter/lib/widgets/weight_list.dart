import 'package:flutter/material.dart';
import '../models/weight_record.dart';
import '../models/user_profile.dart';
import '../models/activity.dart';
import '../theme/app_dimens.dart';
import 'weight_chart.dart';

class WeightListContent extends StatefulWidget {
  final List<WeightRecord> records;
  final double? latestWeight;
  final double? averageWeightLast7Days;
  final ({bool isUp, double diff})? weekOverWeekChange;
  final void Function(WeightRecord) onDelete;
  final void Function(List<WeightRecord>) onDeleteBatch;
  final UserProfile userProfile;

  const WeightListContent({
    super.key,
    required this.records,
    required this.latestWeight,
    this.averageWeightLast7Days,
    this.weekOverWeekChange,
    required this.onDelete,
    required this.onDeleteBatch,
    this.userProfile = const UserProfile(),
  });

  @override
  State<WeightListContent> createState() => _WeightListContentState();
}

class _WeightListContentState extends State<WeightListContent> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) _selectedIds.clear();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == widget.records.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(widget.records.map((r) => r.id));
      }
    });
  }

  void _toggleRecord(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    final toDelete = widget.records.where((r) => _selectedIds.contains(r.id)).toList();
    if (toDelete.isEmpty) return;
    widget.onDeleteBatch(toDelete);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedIds.clear();
          _isSelectionMode = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedForChart = List<WeightRecord>.from(widget.records)
      ..sort((a, b) => a.date.compareTo(b.date));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH, vertical: AppDimens.sectionSpacing),
      children: [
        if (widget.records.length >= 2) WeightChart(records: sortedForChart, targetWeight: widget.userProfile.expectedWeightKg),
        if (widget.records.length >= 2) const SizedBox(height: AppDimens.sectionSpacing),
        if (widget.latestWeight != null) ...[
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
                            '${(widget.latestWeight ?? 0).toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (widget.userProfile.hasExpectedWeight && widget.userProfile.expectedWeightKg != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '预期 ${widget.userProfile.expectedWeightKg!.toStringAsFixed(1)} kg · 距预期 ${((widget.latestWeight ?? 0) - widget.userProfile.expectedWeightKg!).toStringAsFixed(1)} kg',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                          if (widget.userProfile.hasHeight && widget.latestWeight != null && widget.userProfile.bmi(widget.latestWeight!) != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'BMI ${widget.userProfile.bmi(widget.latestWeight!)!.toStringAsFixed(1)} (${widget.userProfile.bmiCategory(widget.userProfile.bmi(widget.latestWeight!)!)})',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ] else if (!widget.userProfile.hasHeight) ...[
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
                  if (widget.averageWeightLast7Days != null || widget.weekOverWeekChange != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (widget.averageWeightLast7Days != null)
                          Expanded(
                            child: _StatBlock(
                              label: '7 日均值',
                              value: widget.userProfile.hasHeight && widget.userProfile.bmi(widget.averageWeightLast7Days!) != null
                                  ? '${widget.averageWeightLast7Days!.toStringAsFixed(1)} kg · BMI ${widget.userProfile.bmi(widget.averageWeightLast7Days!)!.toStringAsFixed(1)}'
                                  : '${widget.averageWeightLast7Days!.toStringAsFixed(1)} kg',
                            ),
                          ),
                        if (widget.averageWeightLast7Days != null && widget.weekOverWeekChange != null) const SizedBox(width: 8),
                        if (widget.weekOverWeekChange != null)
                          Expanded(
                            child: _WeekCompareBlock(change: widget.weekOverWeekChange!),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '历史记录',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (_isSelectionMode)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    onPressed: _toggleSelectAll,
                    child: Text(_selectedIds.length == widget.records.length ? '取消全选' : '全选'),
                  ),
                  TextButton(
                    onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
                    child: Text('删除 (${_selectedIds.length})', style: const TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: _toggleSelectionMode,
                    child: const Text('取消'),
                  ),
                ],
              )
            else
              TextButton(
                onPressed: _toggleSelectionMode,
                child: const Text('多选'),
              ),
          ],
        ),
        const SizedBox(height: AppDimens.listItemSpacing),
        ...widget.records.map((r) => _WeightItem(
              record: r,
              isSelectionMode: _isSelectionMode,
              isSelected: _selectedIds.contains(r.id),
              onTap: () => _isSelectionMode ? _toggleRecord(r.id) : null,
              onDelete: () => widget.onDelete(r),
            )),
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
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _WeightItem({
    required this.record,
    required this.isSelectionMode,
    required this.isSelected,
    this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final activities = record.activities
        .map((id) => Activity.fromId(id))
        .whereType<Activity>()
        .toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
      margin: const EdgeInsets.only(bottom: AppDimens.listItemSpacing),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        child: ListTile(
          leading: isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: onTap != null ? (_) => onTap!() : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                )
              : null,
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
          trailing: isSelectionMode ? null : IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
