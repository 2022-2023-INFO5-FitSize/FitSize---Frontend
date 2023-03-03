import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'UserProvider.dart';
import 'detailClothes.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  late PageController _pageController;
  int currentPage = 0;

  List<String> names = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPage);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final login = userProvider.user.login;
    fetchData(login);
  }

  // Fonction qui récupère le mot de passe dans un Json
  List<String> getNameFromJson(List<dynamic> jsonList) {
    List<String> names = [];
    for (var item in jsonList) {
      final name = item['name'];
      if (name != null && name.isNotEmpty) {
        names.add(name);
      }
    }
    return names;
  }

  Future<void> fetchData(String login) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/polls/usermodel/login/$login'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final names = getNameFromJson(jsonData);
      setState(() {
        this.names = names;
      });
    } else {
      throw Exception('Failed to load names');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          final name = names[index];
          return ElevatedButton(
            child: Text(name),
            onPressed: () {},
          );
        },
      ),
    );
  }
}
