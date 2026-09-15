import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.loadPersistedData();
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const CampusCelebrationHallApp(),
    ),
  );
}

class CampusCelebrationHallApp extends StatelessWidget {
  const CampusCelebrationHallApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'Campus Celebration Hall',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      home: const SplashScreen(),
    );
  }
}
