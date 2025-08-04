import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nazokake/firebase_options.dart';
import 'package:nazokake/pages/TermsAgreement.dart';
import 'package:nazokake/pages/TimelineScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'nazokake share',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: Color.fromARGB(255, 250, 176, 232), // 任意の色
          secondary: Color.fromARGB(255, 255, 232, 255),
          onPrimary: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
      ),
      home: TimelineScreen(),
    );
  }
}
