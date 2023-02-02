import 'package:flutter/material.dart';

class DetailClothesPage extends StatelessWidget {

  final String image;

  const DetailClothesPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail"),
      ),
      body: Center(
        child: Image (
            image: AssetImage(image),
        ),
      ),
    );
  }
}

