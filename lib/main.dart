import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:meet_presence_front/screens/HomeScreen.dart';
import 'package:meet_presence_front/screens/login/LoginScreen.dart';
import 'package:meet_presence_front/screens/login/SignUpScreen.dart';

void main() {
  Intl.defaultLocale =
      'en'; // Establece un idioma predeterminado si no se puede determinar el idioma del teléfono

  runApp(const MeetPresenceApp());
}

class MeetPresenceApp extends StatelessWidget {
  const MeetPresenceApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        // Agrega las localizaciones compatibles con tu aplicación
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        // Agrega los locales compatibles con tu aplicación
        const Locale('en', 'US'), // Inglés
        const Locale('es', 'ES'), // Español
        // ...
      ],
      debugShowCheckedModeBanner: false,
      title: 'TalkTally - Hablar cuenta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/homeScreen': (context) => HomeScreen(),

      },
    );
  }
}
