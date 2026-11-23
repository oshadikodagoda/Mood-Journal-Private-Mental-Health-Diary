import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // <-- 1. Add this
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // <-- 2. Add this
import 'package:sqflite/sqflite.dart'; // <-- 3. Add this
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'providers/journal_provider.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SQLite for Web (Chrome)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWebNoWebWorker;
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MoodJournalApp(),
    ),
  );
}

class MoodJournalApp extends StatelessWidget {
  const MoodJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Mood Journal',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      
      // Light Theme (Pastel Cream & Sage)
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.accentColor,
          primary: themeProvider.accentColor,
          secondary: const Color(0xFFF4D6D6),
          surface: const Color(0xFFFAF6EF),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF6EF),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF6EF),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        ),
      ),

      // Dark Theme (Charcoal & Sage)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: themeProvider.accentColor,
          primary: themeProvider.accentColor,
          surface: const Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}