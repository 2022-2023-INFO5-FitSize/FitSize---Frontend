import 'package:fitsize/Catalogue.dart';
import 'package:fitsize/Login.dart';
import 'package:fitsize/UserProvider.dart';
import 'package:fitsize/app.dart';
import 'package:fitsize/home.dart';
import 'package:fitsize/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsize/Catalogue.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'User.dart';
import 'UserProvider.dart';
import 'main.dart';
import 'dart:convert';
import 'package:get/get.dart';

void main() {
  runApp(MaterialApp(
    home: const LoginApp(),
  ));
}

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<StatefulWidget> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  final formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  late int userId;

  // Fonction qui récupère le mot de passe dans un Json
  String getPasswordFromJson(String jsonStr) {
    Map<String, dynamic> jsonMap = json.decode(jsonStr);
    String password = jsonMap["password"];
    return password;
  }

  // Fonction qui récupère l'id dans un Json
  int getIdFromJson(String jsonStr) {
    Map<String, dynamic> jsonMap = json.decode(jsonStr);
    int id = jsonMap["id"];
    return id;
  }

  // Fonction qui fait une requete GET pour vérifier les champs
  Future<void> submitForm() async {
    Navigator.push(
        // On accède a l'accueil
        context,
        MaterialPageRoute(builder: (context) => HomePage()));
    if (formKey.currentState != null) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        try {
          final response = await http.get(
            Uri.parse("http://10.0.2.2:8000/polls/user/login/$email"),
          );
          if (response.statusCode == 200) {
            if (password == getPasswordFromJson(response.body)) {
              userId = getIdFromJson(response.body);
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.setUser(User(id: userId));
              print("lol");
              Get.to(MainApp());
            } else {
              print("erreur");
            }
          }
        } catch (e) {
          // error
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Se connecter',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              )),
          body: Center(
              child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Image.asset(
                    'assets/images/FitSizeLogo.png',
                    height: 130,
                    width: 130,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      labelText: 'E-mail',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Entrez votre e-mail';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      labelText: 'Mot de passe',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Entrez votre mot de passe';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      password = value!;
                    },
                  ),
                ),
                Container(
                    height: 80,
                    width: 250,
                    padding: const EdgeInsets.fromLTRB(40, 30, 40, 0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                      ),
                      onPressed: submitForm,
                      child: const Text('Connexion'),
                    )),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ))),
    );
  }
}
