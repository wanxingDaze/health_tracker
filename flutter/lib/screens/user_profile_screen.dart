import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_repository.dart';
import '../theme/app_dimens.dart';

class UserProfileScreen extends StatefulWidget {
  final UserRepository userRepository;

  const UserProfileScreen({super.key, required this.userRepository});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _expectedWeightController;
  Gender? _gender;

  @override
  void initState() {
    super.initState();
    final p = widget.userRepository.profile;
    _ageController = TextEditingController(text: p.age?.toString() ?? '');
    _heightController = TextEditingController(text: p.heightCm?.toString() ?? '');
    _expectedWeightController = TextEditingController(text: p.expectedWeightKg?.toString() ?? '');
    _gender = p.gender;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _expectedWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('用户资料'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePaddingH, vertical: AppDimens.sectionSpacing),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('基本信息', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '年龄',
                      hintText: '请输入年龄',
                      suffixText: '岁',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '身高',
                      hintText: '请输入身高',
                      suffixText: 'cm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _expectedWeightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '预期体重',
                      hintText: '目标体重（可选）',
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('性别', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('男'),
                        selected: _gender == Gender.male,
                        onSelected: (v) => setState(() => _gender = v ? Gender.male : null),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('女'),
                        selected: _gender == Gender.female,
                        onSelected: (v) => setState(() => _gender = v ? Gender.female : null),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('BMI 说明', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'BMI = 体重(kg) ÷ 身高²(m²)\n'
                    '• 偏瘦: < 18.5\n'
                    '• 正常: 18.5 ~ 24\n'
                    '• 超重: 24 ~ 28\n'
                    '• 肥胖: ≥ 28',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final age = int.tryParse(_ageController.text.trim());
    final heightCm = double.tryParse(_heightController.text.trim());
    final expectedWeightKg = double.tryParse(_expectedWeightController.text.trim());
    final profile = UserProfile(
      age: age,
      heightCm: heightCm,
      gender: _gender,
      expectedWeightKg: expectedWeightKg != null && expectedWeightKg > 0 ? expectedWeightKg : null,
    );
    await widget.userRepository.save(profile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
      Navigator.of(context).pop();
    }
  }
}
