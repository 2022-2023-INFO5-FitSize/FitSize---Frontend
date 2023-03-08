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
  late double neckline = 0.0;
  bool isLoading = true;
  Map<String, double> dimensionsMap = {};

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

  Map<String, double> parseDimensions(String str) {
    String cleanStr = str.replaceAll(RegExp(r'[{} ]'), '');
    List<String> keyValuePairs = cleanStr.split(',');
    Map<String, double> values = {};
    for (String pair in keyValuePairs) {
      List<String> keyValue = pair.split(':');
      String key = keyValue[0].replaceAll("'", "");
      double value = double.parse(keyValue[1]);
      values[key] = value;
    }
    return values;
  }

  fetchData(idClothes) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/polls/usermodel/$idClothes'));

    if (response.statusCode == 200) {
      parseJson(response.body);
      dimensionsMap = parseDimensions(
          dimensions); // stocke proprement les dimensions dans une map
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black, // ou toute autre couleur
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'Détail de $name',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/slipwomarks.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            isLoading // Vérifier si les données ont été chargées avec succès
                ? Text(
                    '',
                    style: TextStyle(fontSize: 20),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: dimensionsMap.length,
                      itemBuilder: (context, index) {
                        String key = dimensionsMap.keys.elementAt(index);
                        double? value = dimensionsMap[key];
                        return ListTile(
                          title: Text(
                            key,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(value.toString()),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
