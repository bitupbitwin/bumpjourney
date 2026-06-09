import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseService.init(); // 桌面端 sqflite ffi 初始化
  // 本地通知初始化失败不应阻断启动(某些机型权限/插件异常会导致整 App 闪退)
  try {
    await NotificationService.instance.init(); // 本地通知 + 时区
  } catch (e, st) {
    debugPrint('NotificationService.init 失败,已忽略: $e\n$st');
  }
  // 纯竖屏(Portrait Only)
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: const BumpJourneyApp(),
    ),
  );
}

class BumpJourneyApp extends StatelessWidget {
  const BumpJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppState>().role;
    return MaterialApp(
      title: '孕育时光 · BumpJourney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(role),
      home: const HomeShell(),
    );
  }
}
