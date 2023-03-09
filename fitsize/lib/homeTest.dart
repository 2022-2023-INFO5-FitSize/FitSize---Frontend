import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

import 'package:provider/provider.dart';

import 'UserProvider.dart';

class HomePageTest extends StatefulWidget {
  const HomePageTest({Key? key}) : super(key: key);

  @override
  State<HomePageTest> createState() => _HomePageTestState();
}

class _HomePageTestState extends State<HomePageTest> {
  String taskId = "";
  Map<String, double> dimensions = {};
  late final login;
  late final idUser;
  late final password;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    login = userProvider.user.login;
    idUser = userProvider.user.id;
    password = userProvider.user.password;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Cette fonction appelle l'api IA et ajoute le vetement dans la base de donnée
  void handlingData(String imagePath) async {
    try {
      setState(() {
        isLoading = true;
      });
      final bytes = (await rootBundle.load(imagePath)).buffer.asUint8List();
      String base64string = base64.encode(bytes);

      // POST
      var response = await http.post(
        Uri.parse("http://127.0.0.1:8000/keypoints/execScript/"),
        body: jsonEncode(
            <String, String>{"clothing": "trousers", "image": base64string}),
      );
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      taskId = jsonData["task_id"];

      // On attend que la tâche est complété
      var statusUrl =
          Uri.parse('http://127.0.0.1:8000/keypoints/taskStatus/$taskId');

      //GET
      var statusResponse = await http.get(statusUrl);
      var status = json.decode(statusResponse.body)['status'];
      while (status != 'SUCCESS') {
        await Future.delayed(Duration(seconds: 1));
        statusResponse = await http.get(statusUrl);
        status = json.decode(statusResponse.body)['status'];
      }

      // On calcule les dimensions et on ajoute dans la base de donnée
      if (statusResponse.statusCode == 200) {
        dimensions = calculateDimensions(statusResponse
            .body); // on stocke les dimensions de la photo dans une map
        postClothing(dimensions);
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Cette fonction calcule les dimensions
  Map<String, double> calculateDimensions(String input) {
    final res = json.decode(input);
    const typeClothe = 'trousers';
    final keypoints = res['result']['keypoints'];

    final dimensions = <String, double>{};

    Map<String, dynamic> CONNECTIONS = {
      'trousers': {
        "waistband": {'waistband_left', 'waistband_right'},
        "left_leg": {'waistband_left', 'bottom_left_out'},
        "right_leg": {'waistband_right', 'bottom_right_out'},
      }
    };

    for (var entry in CONNECTIONS[typeClothe].entries) {
      List<num> tmp = <num>[];
      for (var value in entry.value) {
        String arrayString = keypoints?[value];

        List<String> stringValues =
            arrayString.split("[")[1].split("]")[0].split(",");
        List<int> values =
            stringValues.map((e) => int.parse(e.trim())).toList();

        String dtype = arrayString.split("dtype=")[1].split(")")[0];
        var npArray = NumpyArray.fromList(values, dtype: dtype);

        tmp.add(npArray[0]);
      }
      double distance =
          (tmp[0] - tmp[1]).abs() / res["result"]["cb_box_distance"];
      dimensions[entry.key] = double.parse((distance).toStringAsFixed(2));
    }

    return dimensions;
  }

  // Cette fonction ajoute le vetement dans la base de données
  Future<void> postClothing(Map<String, double> dims) async {
    var url = Uri.parse('http://127.0.0.1:8000/polls/usermodel/');
    String dimensionsFinal = jsonEncode(dims);
    // Remplacer les guillemets doubles par des guillemets simples
    dimensionsFinal = dimensionsFinal.replaceAll('"', "'");

    // on créer l'objet data
    var data = {
      "name": "Calecon",
      "dimensions": dimensionsFinal,
      "user": idUser,
      "clothingtype": 3
    };

    var jsonData = jsonEncode(data);
    // requete POST
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );

    if (response.statusCode == 201) {
      print('Data added successfully!');
    } else {
      print('Failed to add data to database');
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
                  'Accueil',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Image.asset(
                'assets/images/slipwomarks.jpg',
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 50),
              Visibility(
                visible: isLoading, // visible only when isLoading is true
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: IconButton(
                  onPressed: () {
                    handlingData("assets/images/slipwomarks.jpg");
                  },
                  icon: Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                  ),
                  iconSize: 40,
                ),
              ),
            ],
          )),
    );
  }
}

class NumpyArray {
  List<num> data;
  String dtype;

  NumpyArray({required this.data, required this.dtype});

  factory NumpyArray.fromList(List<int> list, {required String dtype}) {
    var data = list.map((e) => e.toDouble()).toList();
    return NumpyArray(data: data, dtype: dtype);
  }

  num operator [](int index) {
    return data[index];
  }
}
