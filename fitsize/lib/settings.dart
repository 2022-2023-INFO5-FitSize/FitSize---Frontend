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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/FitSizeLogo.png',
                  scale: 5,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Catalogue',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            )),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bonjour $login",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text("Se déconnecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
