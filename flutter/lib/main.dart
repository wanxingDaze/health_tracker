import 'package:flutter/material.dart';
import 'theme/app_dimens.dart';
import 'screens/main_screen.dart';
import 'services/weight_repository.dart';
import 'services/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final weightRepo = WeightRepository();
  final userRepo = UserRepository();
  await Future.wait([weightRepo.load(), userRepo.load()]);
  runApp(HealthTrackerApp(weightRepository: weightRepo, userRepository: userRepo));
}

class HealthTrackerApp extends StatelessWidget {
  final WeightRepository weightRepository;
  final UserRepository userRepository;

  const HealthTrackerApp({super.key, required this.weightRepository, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '体重记录',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A96F5)),
        useMaterial3: true,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size(48, AppDimens.buttonMinHeight)),
          ),
        ),
      ),
      home: MainScreen(weightRepository: weightRepository, userRepository: userRepository),
    );
  }
}
