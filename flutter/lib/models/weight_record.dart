class WeightRecord {
  final String id;
  final double weight;
  final DateTime date;
  final String? note;
  final List<String> activities;

  WeightRecord({
    required this.id,
    required this.weight,
    required this.date,
    this.note,
    this.activities = const [],
  });

  String get formattedWeight => '${weight.toStringAsFixed(1)} kg';

  String get formattedDate {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight': weight,
        'date': date.millisecondsSinceEpoch,
        'note': note,
        'activities': activities,
      };

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    final activitiesRaw = json['activities'];
    final activities = activitiesRaw is List
        ? (activitiesRaw).map((e) => e.toString()).toList()
        : <String>[];
    return WeightRecord(
      id: json['id'] as String,
      weight: (json['weight'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      note: json['note'] as String?,
      activities: activities,
    );
  }
}
