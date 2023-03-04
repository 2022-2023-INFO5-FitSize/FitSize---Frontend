import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'UserProvider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final login = userProvider.user.login;
    print(login);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Paramètres'),
        ),
        body: const Center(child: Text('Page Paramètre')),
      ),
    );
  }
}
