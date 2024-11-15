import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verifyone/core/services/login_provider.dart';
import 'package:verifyone/core/view/screens/authentications/login_screen.dart';
import 'package:verifyone/core/view_models/porviders/main_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCrT7GIcWKwLO5QcZASM9BCl0yIUL9iLjA",
      appId: "1:945567739219:android:b4fc572716dd3027b8c5a6",
      messagingSenderId: "945567739219",
      projectId: "verifyone-901ec",
      storageBucket: "verifyone-901ec.firebasestorage.app",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainProvider()),
        ChangeNotifierProvider(create: (_) => LoginProviderNew()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
