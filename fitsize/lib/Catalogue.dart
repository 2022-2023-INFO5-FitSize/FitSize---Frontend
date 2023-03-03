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
  Map<int, String> data = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPage);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final login = userProvider.user.login;
    fetchData(login);
  }

  // Fonction qui parse le json et stocke dans une map, l'id et le nom du vetement
  Map<int, String> parseJsonToMap(String jsonString) {
    List<dynamic> data = json.decode(jsonString);
    Map<int, String> result = {};

    for (dynamic item in data) {
      int id = item['id'];
      String name = item['name'];
      result[id] = name;
    }

    return result;
  }

  // Fonction qui récupère les données
  Future<void> fetchData(String login) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/polls/usermodel/login/$login'));

    if (response.statusCode == 200) {
      final data = parseJsonToMap(response.body);
      setState(() {
        this.data = data;
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
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          int id = data.keys.elementAt(index);
          String? name = data[id];
          return ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailClothesPage(idUser: id)));
            },
            child: Text(name!),
          );
        },
      ),
    );
  }
}
