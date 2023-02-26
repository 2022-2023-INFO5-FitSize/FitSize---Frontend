import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  late String email;
  late String password;

  Future<void> submitForm() async {
    if (formKey.currentState != null) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        try {
          final response = await http.get(
            Uri.parse("http://10.0.2.2:8000/polls/user?login=$email&password=$password"),
          );
          print(response.body);
          if (response.statusCode == 200) {
            print("ok");
          } else {
            print("erreur");
          }
        } catch (e) {
          // error
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Connexion'),
        ),
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
                      minimumSize: const Size.fromHeight(50),
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
        )));
  }
}
