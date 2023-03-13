import 'package:fitsize/catalogue.dart';
import 'package:fitsize/home.dart';
import 'package:fitsize/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
          ),
        ],
        activeColor: Colors.indigo,
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(child: HomePage());
              },
            );
          case 1:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(child: CataloguePage());
              },
            );
          default:
            return CupertinoTabView(
              builder: (context) {
                return const CupertinoPageScaffold(child: SettingsPage());
              },
            );
        }
      },
      backgroundColor: Colors.white,
      // Set the background color of the tab scaffold
      resizeToAvoidBottomInset:
          true, // Ensure that content is not covered by the device's bottom system UI elements
    );
  }
}
