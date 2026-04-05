// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/game/providers/game_provider.dart';
import 'features/game/ui/game_screen.dart';
import 'features/settings/providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
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
          ),
          home: const GameScreen(),
        );
      },
    );
  }
}
