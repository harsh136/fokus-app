import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/folder.dart';
import 'models/note.dart';
import 'services/app_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Local Storage
  await Hive.initFlutter();
  Hive.registerAdapter(FolderAdapter());
  Hive.registerAdapter(NoteAdapter());

  final provider = AppProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const FokusApp(),
    ),
  );
}

class FokusApp extends StatelessWidget {
  const FokusApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFEDE9E2);
    const textColor = Color(0xFF1C1C1C);

    return MaterialApp(
      title: 'Fokus.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
          titleTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: textColor,
          selectionColor: Color(0xFFD8D5CE),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}