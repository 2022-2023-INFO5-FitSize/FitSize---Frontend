import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CameraDescription> cameras = [];
  late CameraController cameraController;
  bool _cameraInitialized = false;

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

  @override
  Widget build(BuildContext) {
    if (cameraController.value.isInitialized && _cameraInitialized == true) {
      return Scaffold(
        body: Stack(
          children: [
            CameraPreview(cameraController),
            GestureDetector(
              onTap: () {
                cameraController.takePicture().then((XFile? file) {
                  if (mounted) {
                    if (file != null) {
                      print("Picture saved to ${file.path}");
                    }
                  }
                });
              },
              child: button(Icons.camera, Alignment.bottomCenter),
            )
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
