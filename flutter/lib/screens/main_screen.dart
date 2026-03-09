import 'package:flutter/material.dart';
import '../models/weight_record.dart';
import '../services/weight_repository.dart';
import '../services/user_repository.dart';
import '../widgets/weight_chart.dart';
import '../widgets/weight_list.dart';
import '../widgets/add_weight_dialog.dart';
import 'user_profile_screen.dart';

class MainScreen extends StatelessWidget {
  final WeightRepository weightRepository;
  final UserRepository userRepository;

  const MainScreen({super.key, required this.weightRepository, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('体重记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(userRepository: userRepository),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              final days = int.tryParse(value);
              if (days != null) weightRepository.loadSimulatedData(days);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: '7', child: Row(children: [Icon(Icons.science_outlined, size: 20), SizedBox(width: 8), Text('模拟 7 天')])),
              const PopupMenuItem(value: '30', child: Row(children: [Icon(Icons.science_outlined, size: 20), SizedBox(width: 8), Text('模拟 30 天')])),
              const PopupMenuItem(value: '365', child: Row(children: [Icon(Icons.science_outlined, size: 20), SizedBox(width: 8), Text('模拟 365 天')])),
              const PopupMenuItem(value: '500', child: Row(children: [Icon(Icons.science_outlined, size: 20), SizedBox(width: 8), Text('模拟 500 天')])),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([weightRepository, userRepository]),
        builder: (context, _) {
          if (weightRepository.records.isEmpty) {
            return _buildEmptyState();
          }
          return WeightListContent(
            records: weightRepository.records,
            latestWeight: weightRepository.latestWeight,
            averageWeightLast7Days: weightRepository.averageWeightLast7Days,
            weekOverWeekChange: weightRepository.weekOverWeekChange,
            onDelete: weightRepository.delete,
            userProfile: userRepository.profile,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_weight_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无记录',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 添加第一条体重记录',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddWeightDialog(
        onSave: (record) => weightRepository.add(record),
      ),
    );
  }
}
