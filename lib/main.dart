// lib/main.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/services/ad_service.dart';
import 'core/theme/dialog_colors.dart';
import 'features/game/providers/game_provider.dart';
import 'features/game/ui/game_screen.dart';
import 'features/settings/providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(AdService.instance.init());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        final textColor = getDialogTextColor(theme.backgroundColor);
        return MaterialApp(
          title: '2048 Master',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            // fontFamily: 'ClearSans',
            scaffoldBackgroundColor: theme.backgroundColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.scoreTileColor,
              surface: theme.backgroundColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: theme.backgroundColor,
              surfaceTintColor: Colors.transparent,
              titleTextStyle: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          ),
          home: const GameScreen(),
        );
      },
    );
  }
}
