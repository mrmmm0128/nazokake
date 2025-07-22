import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nazokake/firebase_options.dart';
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
      title: 'nazokake share',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: TimelineScreen(),
    );
  }
}
