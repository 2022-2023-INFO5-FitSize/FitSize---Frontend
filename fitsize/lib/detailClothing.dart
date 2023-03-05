import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailClothesPage extends StatefulWidget {
  final int idClothes;

  const DetailClothesPage({super.key, required this.idClothes});

  @override
  State<DetailClothesPage> createState() => _DetailsClothesState();
}

class _DetailsClothesState extends State<DetailClothesPage> {
  late String name = '';
  late String dimensions = '';
  late String typeOfClothing = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData(widget.idClothes);
  }

  void parseJson(String jsonString) {
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    name = jsonData["name"];
    dimensions = jsonData["dimensions"];
    typeOfClothing = jsonData["clothingtype"]["label"];
  }

  fetchData(idClothes) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/polls/usermodel/$idClothes'));

    if (response.statusCode == 200) {
      parseJson(response.body);
      setState(() {
        isLoading =
            false; // Actualiser isLoading après avoir récupéré les données
      });
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détail de $name"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Image.asset(
                'assets/images/tshirt.jpeg',
                width: 300,
                height: 300,
              ),
            ),
            isLoading // Vérifier si les données ont été chargées avec succès
                ? Text(
                    '',
                    style: TextStyle(fontSize: 20),
                  )
                : Text(
                    '$dimensions',
                    style: TextStyle(fontSize: 20),
                  ),
          ],
        ),
      ),
    );
  }
}
