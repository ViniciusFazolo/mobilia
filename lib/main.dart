import 'package:flutter/material.dart';
import 'package:mobilia/pages/welcome.dart';
import 'package:mobilia/pages/dashboard.dart';
import 'package:mobilia/pages/properties_page.dart';
import 'package:mobilia/pages/units_page.dart';
import 'package:mobilia/pages/residents_page.dart';
import 'package:mobilia/pages/contracts_page.dart';
import 'package:mobilia/pages/parcels_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobília',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const Welcome(),
        '/dashboard': (context) => const Dashboard(),
        '/properties': (context) => const PropertiesPage(),
        '/units': (context) => const UnitsPage(),
        '/residents': (context) => const ResidentsPage(),
        '/contracts': (context) => const ContractsPage(),
        '/parcels': (context) => const ParcelsPage(),
      },
    );
  }
}