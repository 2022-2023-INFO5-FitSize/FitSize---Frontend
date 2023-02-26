import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CameraDescription> cameras = [];
  late CameraController cameraController;
  bool _cameraInitialized = false;
  String _dropdownValue = "Shirt";

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

  void sendPicture(String imagePath) async {
    try {
      File imagefile = File(imagePath);
      Uint8List imagebytes = await imagefile.readAsBytes();
      String base64string = base64.encode(imagebytes);

      var response = await http.post(
        Uri.parse("http://10.0.2.2:8000/keypoints/execScript/"),
        body: {"clothing": _dropdownValue, "image": base64string},
      );
      print(response.body);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext) {
    if (cameraController.value.isInitialized && _cameraInitialized == true) {
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
                  'Accueil',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            )),
        body: Stack(
          children: [
            CameraPreview(cameraController),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(
                left: 0,
                bottom: 100,
              ),
              child: DropdownButton(
                items: const [
                  DropdownMenuItem(child: Text("Shirt"), value: "Shirt"),
                  DropdownMenuItem(child: Text("Pantalon"), value: "Pantalon"),
                  DropdownMenuItem(child: Text("Pull"), value: "Pull"),
                  DropdownMenuItem(child: Text("trousers"), value: "trousers"),
                ],
                value: _dropdownValue,
                onChanged: dropdownCallback,
                iconEnabledColor: Colors.blue,
              ),
            ),
            GestureDetector(
              onTap: () {
                cameraController.takePicture().then((XFile? file) {
                  if (mounted) {
                    if (file != null) {
                      print("Picture saved to ${file.path}");
                      print(
                          "YOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
                      sendPicture(file.path); // Envoie la requete au serveur
                    }
                  }
                });
              },
              child: button(Icons.camera, Alignment.bottomCenter),
            ),
          ],
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
          bottom: 20,
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
        child: const Center(
          child: Icon(Icons.camera_alt_outlined),
        ),
      ),
    );
  }
}
