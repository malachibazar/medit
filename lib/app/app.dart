import 'package:flutter/cupertino.dart';
import '../screens/home_screen.dart';
import 'theme/app_colors.dart';

/// Root application widget that configures theme and global settings.
/// This widget follows system brightness for automatic light/dark mode switching.
class MeditApp extends StatelessWidget {
  const MeditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Medit',
      debugShowCheckedModeBanner: false,
      // Theme follows system brightness automatically
      theme: const CupertinoThemeData(
        primaryColor: AppColors.accent,
        // brightness is not set here - it will follow system automatically
      ),
      home: const HomeScreen(),
    );
  }
}
