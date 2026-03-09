enum Gender { male, female }

class UserProfile {
  final int? age;
  final double? heightCm;
  final Gender? gender;
  final double? expectedWeightKg;

  const UserProfile({
    this.age,
    this.heightCm,
    this.gender,
    this.expectedWeightKg,
  });

  bool get hasHeight => heightCm != null && heightCm! > 0;
  bool get hasExpectedWeight => expectedWeightKg != null && expectedWeightKg! > 0;

  double? bmi(double weightKg) {
    if (!hasHeight) return null;
    final h = heightCm! / 100;
    return weightKg / (h * h);
  }

  String bmiCategory(double bmi) {
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '超重';
    return '肥胖';
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'heightCm': heightCm,
        'gender': gender?.index,
        'expectedWeightKg': expectedWeightKg,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        age: json['age'] as int?,
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        gender: json['gender'] != null ? Gender.values[json['gender'] as int] : null,
        expectedWeightKg: (json['expectedWeightKg'] as num?)?.toDouble(),
      );

  UserProfile copyWith({int? age, double? heightCm, Gender? gender, double? expectedWeightKg}) => UserProfile(
        age: age ?? this.age,
        heightCm: heightCm ?? this.heightCm,
        gender: gender ?? this.gender,
        expectedWeightKg: expectedWeightKg ?? this.expectedWeightKg,
      );
}
