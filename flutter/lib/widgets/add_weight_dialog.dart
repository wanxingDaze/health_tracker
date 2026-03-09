import 'package:flutter/material.dart';
import '../models/weight_record.dart';
import '../models/activity.dart';
import '../theme/app_dimens.dart';

class AddWeightDialog extends StatefulWidget {
  final Future<void> Function(WeightRecord) onSave;

  const AddWeightDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<AddWeightDialog> {
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedActivities = {};
  bool _isSaving = false;

  void _toggleActivity(Activity a) {
    setState(() {
      if (a.isRest) {
        _selectedActivities.clear();
        _selectedActivities.add(a.id);
      } else {
        _selectedActivities.remove(Activity.rest.id);
        if (_selectedActivities.contains(a.id)) {
          _selectedActivities.remove(a.id);
        } else {
          _selectedActivities.add(a.id);
        }
      }
    });
  }

  Widget _buildActivityRow(List<Activity> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((a) {
        final selected = _selectedActivities.contains(a.id);
        return FilterChip(
            label: Text(a.label),
            selected: selected,
            onSelected: (_) => _toggleActivity(a),
            showCheckmark: false,
            selectedColor: a.color.withValues(alpha: 0.35),
            backgroundColor: Colors.grey.shade200,
            side: BorderSide(color: selected ? a.color : Colors.grey.shade300, width: selected ? 2 : 1),
          );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final w = double.tryParse(_weightController.text);
    return w != null && w > 0 && w < 500;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _save() async {
    if (!_isValid || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      final record = WeightRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        weight: double.parse(_weightController.text),
        date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        activities: _selectedActivities.toList(),
      );
      await widget.onSave(record);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加记录'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppDimens.blockRadius),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '日期',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 20),
                ),
                child: Text(
                  '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: AppDimens.sectionSpacing),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: '体重 (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppDimens.sectionSpacing),
            Text('今日活动', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: AppDimens.listItemSpacing),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActivityRow([Activity.fitness, Activity.basketball, Activity.football]),
                const SizedBox(height: AppDimens.listItemSpacing),
                _buildActivityRow([Activity.badminton, Activity.swimming, Activity.running]),
                const SizedBox(height: AppDimens.listItemSpacing),
                _buildActivityRow([Activity.pingpong, Activity.rest]),
              ],
            ),
            const SizedBox(height: AppDimens.sectionSpacing),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppDimens.buttonMinHeight)),
          onPressed: (_isValid && !_isSaving) ? _save : null,
          child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('保存'),
        ),
      ],
    );
  }
}
