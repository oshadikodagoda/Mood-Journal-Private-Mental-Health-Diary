import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'providers/journal_provider.dart';
import 'screens/home_screen.dart';

void main() {
  // Ensure Flutter is initialized before opening the database
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        // Provide the DatabaseService to the entire app
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        // Provide the JournalProvider to manage the list of entries
        ChangeNotifierProvider(create: (_) => JournalProvider()),
      ],
      child: const MoodJournalApp(),
    ),
  );
}

class MoodJournalApp extends StatelessWidget {
  const MoodJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Using the Pastel Colors from your Figma Design
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA8C3A0), // Sage Green
          primary: const Color(0xFFA8C3A0),
          secondary: const Color(0xFFF4D6D6), // Soft Pink
          surface: const Color(0xFFFAF6EF), // Cream Background
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF6EF),
        
        // 1. Default Font for the entire app (Body text, buttons, etc.)
        fontFamily: 'Poppins', 
        
        // 2. AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF6EF),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        
        // 3. Custom Text Theme for Headings (Uses Playfair Display)
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
        ),
      ),
      // Set the Home Screen as the starting point
      home: const HomeScreen(),
    );
  }
}