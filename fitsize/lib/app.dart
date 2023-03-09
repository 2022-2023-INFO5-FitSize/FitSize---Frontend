import 'package:fitsize/Catalogue.dart';
import 'package:fitsize/home.dart';
import 'package:fitsize/homeTest.dart';
import 'package:fitsize/settings.dart';
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
    return CupertinoApp(
        home: CupertinoPageScaffold(
      child: CupertinoTabScaffold(
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
                return CupertinoTabView(builder: (context) {
                  return const CupertinoPageScaffold(child: HomePageTest());
                });
              case 1:
                return CupertinoTabView(builder: (context) {
                  return const CupertinoPageScaffold(child: CataloguePage());
                });
              default:
                return CupertinoTabView(builder: (context) {
                  return const CupertinoPageScaffold(child: SettingsPage());
                });
            }
          }),
    ));
  }
}
