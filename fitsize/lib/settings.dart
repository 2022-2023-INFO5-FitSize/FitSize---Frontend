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
                  'Paramètres',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            )),
        body: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              const CircleAvatar(
                radius: 60,
                backgroundImage:
                    NetworkImage('https://picsum.photos/id/58/1280/853.jpg'),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "$login",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                "Bienvenue sur l'application FitSize !",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 300,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                  ),
                  onPressed: () {

                  },
                  child: const Text('Deconnexion'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
