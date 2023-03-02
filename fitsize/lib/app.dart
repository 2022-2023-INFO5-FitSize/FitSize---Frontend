import 'package:fitsize/Catalogue.dart';
import 'package:fitsize/Login.dart';
import 'package:fitsize/UserProvider.dart';
import 'package:fitsize/home.dart';
import 'package:fitsize/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _index = 1;
  final screens = [
    const CataloguePage(),
    HomePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
      child: Scaffold(
          body: screens[_index],
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: _index,
              onTap: (value) {
                setState(() {
                  _index = value;
                });
              },
              backgroundColor: const Color.fromARGB(255, 227, 227, 227),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Catalogue',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.photo_camera),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Paramètres',
                ),
              ])),
    ));
  }
}