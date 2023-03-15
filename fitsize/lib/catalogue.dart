import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'userprovider.dart';
import 'detailclothing.dart';
import 'global.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  late PageController _pageController;
  int currentPage = 0;
  Map<int, String> data = {};
  late final login = "";
  List<String> imgUrlList = [];

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
    List<String> imgList = [];

    for (dynamic item in data) {
      int id = item['id'];
      String name = item['name'];
      String imgUrl = item['image'];
      result[id] = name;
      imgList.add(imgUrl);
    }

    imgUrlList = imgList;

    return result;
  }

  // Fonction qui récupère les données
  Future<void> fetchData(String login) async {
    final response = await http
        .get(Uri.parse('http://$ipAdress:8000/polls/usermodel/login/$login'));

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
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final login = userProvider.user.login;
                fetchData(login);
              },
            ),
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: data.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            int id = data.keys.elementAt(index);
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailClothesPage(idClothes: id),
                  ),
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      imgUrlList[index],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
