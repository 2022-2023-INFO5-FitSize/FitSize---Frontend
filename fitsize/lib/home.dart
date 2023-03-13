import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'userprovider.dart';
import 'package:flutter/services.dart';

import 'global.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CameraDescription> cameras = [];
  late Future<CameraController> cameraControllerFuture;
  late CameraController _cameraController;
  late final login;
  late final idUser;
  late final password;
  bool _cameraInitialized = false;
  String _dropdownValue = "trousers";
  Map<String, double> dimensions = {};
  String taskId = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    login = userProvider.user.login;
    idUser = userProvider.user.id;
    password = userProvider.user.password;
    initCamera().then((cameraController) {
      setState(() {
        _cameraController = cameraController;
        _cameraInitialized = true;
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<CameraController> initCamera() async {
    final cameras = await availableCameras();
    final cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    await cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cameraInitialized = true;
      });
    }).catchError((e) {
      print(e);
    });

    return cameraController;
  }

  @override
  void dispose() {
    cameraControllerFuture.then((cameraController) {
      cameraController.dispose();
    });
    super.dispose();
  }

  void dropdownCallback(String? selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _dropdownValue = selectedValue;
      });
    }
  }

  // Cette fonction ajoute le vetement dans la base de données
  Future<void> postClothing(Map<String, double> dims, String img) async {
    var url = Uri.parse('http://$ipAdress:8000/polls/usermodel/');
    String dimensionsFinal = jsonEncode(dims);
    // Remplacer les guillemets doubles par des guillemets simples
    dimensionsFinal = dimensionsFinal.replaceAll('"', "'");

    // on créer l'objet data
    var data = {
      "name": "",
      "dimensions": dimensionsFinal,
      "user": idUser,
      "clothingtype": 3,
      "images": img
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
        Uri.parse("http://$ipAdress:8000/keypoints/execScript/"),
        body: jsonEncode(
            <String, String>{"clothing": "trousers", "image": base64string}),
      );
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      taskId = jsonData["task_id"];

      // On attend que la tâche est complété
      var statusUrl =
          Uri.parse('http://$ipAdress:8000/keypoints/taskStatus/$taskId');

      //GET
      var statusResponse = await http.get(statusUrl);
      var status = json.decode(statusResponse.body)['status'];
      while (status != 'SUCCESS') {
        await Future.delayed(Duration(seconds: 2));
        statusResponse = await http.get(statusUrl);
        status = json.decode(statusResponse.body)['status'];
      }

      // On calcule les dimensions et on ajoute dans la base de donnée
      if (statusResponse.statusCode == 200) {
        dimensions = calculateDimensions(statusResponse
            .body); // on stocke les dimensions de la photo dans une map
        postClothing(dimensions, imagePath);
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

  // Cette fonction calcule les dimensions à partir d'un string contenant les keypoints
  Map<String, double> calculateDimensions(String input) {
    final res = json.decode(input);
    const typeClothe = 'trousers';
    final keypoints = res['result']['keypoints'];
    final dimensions = <String, double>{};

    Map<String, dynamic> CONNECTIONS = {
      'blouse': {
        "neck": {'neckline_left', 'neckline_right'},
        "shoulders": {'shoulder_left', 'shoulder_right'},
        "left_sleeve": {'shoulder_left', 'cuff_left_out'},
        "right_sleeve": {'shoulder_right', 'cuff_right_out'},
        "left_cuff": {'cuff_left_in', 'cuff_left_out'},
        "right_cuff": {'cuff_right_in', 'cuff_right_out'},
        "chest": {'armpit_left', 'armpit_right'},
        "waist": {'top_hem_left', 'top_hem_right'},
        "length_left": {'shoulder_left', 'top_hem_left'},
        "length_right": {'shoulder_right', 'top_hem_right'},
      },
      'outwear': {
        "neck": {'neckline_left', 'neckline_right'},
        "shoulders": {'shoulder_left', 'shoulder_right'},
        "left_sleeve": {'shoulder_left', 'cuff_left_out'},
        "right_sleeve": {'shoulder_right', 'cuff_right_out'},
        "left_cuff": {'cuff_left_in', 'cuff_left_out'},
        "right_cuff": {'cuff_right_in', 'cuff_right_out'},
        "chest": {'armpit_left', 'armpit_right'},
        "waist": {'waistline_left', 'waistline_right'},
        "length_left": {'shoulder_left', 'waistline_left'},
        "length_right": {'shoulder_right', 'waistline_right'},
      },
      'trousers': {
        "waistband": {'waistband_left', 'waistband_right'},
        "left_leg": {'waistband_left', 'bottom_left_out'},
        "right_leg": {'waistband_right', 'bottom_right_out'},
      },
      'skirt': {
        "waistband": {'waistband_left', 'waistband_right'},
        "hemline": {'hemline_left', 'hemline_right'},
      },
      'dress': {
        "neck": {'neckline_left', 'neckline_right'},
        "shoulders": {'shoulder_left', 'shoulder_right'},
        "left_sleeve": {'shoulder_left', 'cuff_left_out'},
        "right_sleeve": {'shoulder_right', 'cuff_right_out'},
        "left_cuff": {'cuff_left_in', 'cuff_left_out'},
        "right_cuff": {'cuff_right_in', 'cuff_right_out'},
        "chest": {'armpit_left', 'armpit_right'},
        "waist": {'waistline_left', 'waistline_right'},
        "length_left": {'shoulder_left', 'hemline_left'},
        "length_right": {'shoulder_right', 'hemline_right'},
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

  @override
  Widget build(BuildContext context) {
    if (_cameraInitialized) {
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
                const Expanded(
                  child: SizedBox(),
                ),
                DropdownButton(
                  items: const [
                    DropdownMenuItem(value: "blouse", child: Text("blouse")),
                    DropdownMenuItem(value: "dress", child: Text("dress")),
                    DropdownMenuItem(value: "outwear", child: Text("outwear")),
                    DropdownMenuItem(
                        value: "trousers", child: Text("trousers")),
                    DropdownMenuItem(value: "skirt", child: Text("skirt")),
                  ],
                  value: _dropdownValue,
                  onChanged: dropdownCallback,
                  iconEnabledColor: Colors.black,
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              CameraPreview(_cameraController),
              GestureDetector(
                onTap: () {
                  _cameraController.takePicture().then((XFile? file) {
                    if (mounted) {
                      if (file != null) {
                        handlingData(file.path);
                      }
                    }
                  });
                },
                child: button(Icons.camera, Alignment.bottomCenter),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  // cette fonction dessine l'icone capture photo
  Widget button(IconData icon, Alignment alignement) {
    return Align(
      alignment: alignement,
      child: Container(
        margin: const EdgeInsets.only(
          left: 0,
          bottom: 130,
        ),
        height: 70,
        width: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.indigo,
                ),
              )
            : const Center(),
      ),
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
