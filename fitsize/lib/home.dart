import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'UserProvider.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CameraDescription> cameras = [];
  late CameraController cameraController;
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
    startCamera();
    super.initState();
  }

  void startCamera() async {
    final cameras = await availableCameras();

    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
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
  }

  @override
  void dispose() {
    cameraController.dispose();
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
  Future<void> postClothing(Map<String, double> dims) async {
    var url = Uri.parse('http://10.0.2.2:8000/polls/usermodel/');
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
        Uri.parse("http://10.0.2.2:8000/keypoints/execScript/"),
        body: jsonEncode(
            <String, String>{"clothing": "trousers", "image": base64string}),
      );
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      taskId = jsonData["task_id"];

      // On attend que la tâche est complété
      var statusUrl =
          Uri.parse('http://10.0.2.2:8000/keypoints/taskStatus/$taskId');

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

  void sendPicture(String imagePath) async {
    try {
      setState(() {
        isLoading = true;
      });

      File imagefile =
          File("/data/user/0/com.example.fitsize/cache/slipwomarks.jpg");
      Uint8List imagebytes = await imagefile.readAsBytes();
      String base64string = base64.encode(imagebytes);

      var response = await http.post(
        Uri.parse("http://10.0.2.2:8000/keypoints/execScript/"),
        body: jsonEncode(<String, String>{
          "clothing": _dropdownValue,
          "image": base64string
        }),
      );
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      taskId = jsonData["task_id"].toString();

      // On attend que la tâche est complété
      var statusUrl =
          Uri.parse('http://10.0.2.2:8000/keypoints/taskStatus/$taskId');

      //GET
      var statusResponse = await http.get(statusUrl);
      //var status = json.decode(statusResponse.body)['status'];
      while (statusResponse.statusCode != 200) {
        Future.delayed(const Duration(seconds: 1));
        statusResponse = await http.get(statusUrl);
      }
      // On calcule les dimensions et on ajoute dans la base de donnée

      //dimensions = calculateDimensions(statusResponse
      //    .body); // on stocke les dimensions de la photo dans une map
      //postClothing(dimensions);
    } catch (e) {
      print(e);
      throw Exception('Failed to load');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getDataFromTaskId(String id) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/keypoints/taskStatus/$id'));

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController.value.isInitialized && _cameraInitialized == true) {
      return MaterialApp(
        home: SafeArea(
          child: Scaffold(
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
                )),
            body: Stack(
              children: [
                CameraPreview(cameraController),
                GestureDetector(
                  onTap: () {
                    cameraController.takePicture().then((XFile? file) {
                      if (mounted) {
                        if (file != null) {
                          print("Picture saved to ${file.path}");
                          sendPicture(
                              file.path); // Envoie la requete au serveur
                          // requete get pour recevoir les données de la tache
                        }
                      }
                    });
                  },
                  child: button(Icons.camera, Alignment.bottomCenter),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.only(
                    left: 0,
                    bottom: 70,
                  ),
                  child: DropdownButton(
                    items: const [
                      DropdownMenuItem(child: Text("blouse"), value: "blouse"),
                      DropdownMenuItem(child: Text("dress"), value: "dress"),
                      DropdownMenuItem(
                          child: Text("outwear"), value: "outwear"),
                      DropdownMenuItem(
                          child: Text("trousers"), value: "trousers"),
                      DropdownMenuItem(child: Text("skirt"), value: "skirt"),
                    ],
                    value: _dropdownValue,
                    onChanged: dropdownCallback,
                    iconEnabledColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget button(IconData icon, Alignment alignement) {
    return Align(
      alignment: alignement,
      child: Container(
        margin: const EdgeInsets.only(
          left: 0,
          bottom: 130,
        ),
        height: 50,
        width: 50,
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
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.indigo,
                ),
              )
            : const Center(
                child: Icon(Icons.camera_alt_outlined),
              ),
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
