import 'package:flutter/material.dart';

/// 双轨视角:孕妈(暖橙) / 准爸爸(鼠尾草绿)
enum AppRole { mom, dad }

class AppColors {
  static const bg = Color(0xFFFBF6EF);
  static const bgDad = Color(0xFFF6FAF7);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF2C2A28);
  static const sub = Color(0xFF8C857C);
  static const line = Color(0xFFEFE7DB);

  static const mom = Color(0xFFE8916B);
  static const momSoft = Color(0xFFFBE6DB);
  static const dad = Color(0xFF6FA386);
  static const dadSoft = Color(0xFFDCEBE1);

  static const gold = Color(0xFFC9A86A);
  static const goldSoft = Color(0xFFF6EFDF);
  static const custom = Color(0xFF7E6BB0);
  static const customSoft = Color(0xFFEFEAF8);

  static const good = Color(0xFF4E8A63);
  static const goodSoft = Color(0xFFEAF3EC);
  static const bad = Color(0xFFC9594A);
  static const badSoft = Color(0xFFFBEAE6);

  static Color accent(AppRole r) => r == AppRole.mom ? mom : dad;
  static Color accentSoft(AppRole r) => r == AppRole.mom ? momSoft : dadSoft;
  static Color scaffold(AppRole r) => r == AppRole.mom ? bg : bgDad;
}

class AppTheme {
  static ThemeData build(AppRole role) {
    final accent = AppColors.accent(role);
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffold(role),
      fontFamily: null, // 使用系统中文字体(PingFang / 鸿蒙 / Roboto)
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        surface: AppColors.card,
        brightness: Brightness.light,
      ),
      splashColor: accent.withValues(alpha: .12),
      highlightColor: accent.withValues(alpha: .06),
    );
  }

  static const cardShadow = [
    BoxShadow(color: Color(0x1A503C28), blurRadius: 28, offset: Offset(0, 8)),
  ];
}
