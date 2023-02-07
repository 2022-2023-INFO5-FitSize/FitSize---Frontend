import 'package:flutter/material.dart';

class DetailClothesPage extends StatefulWidget {
  final String image;

  const DetailClothesPage({super.key, required this.image});

  @override
  State<DetailClothesPage> createState() => _DetailsCLothesState();
}

class _DetailsCLothesState extends State<DetailClothesPage> {
  late String size = "XS";
  late String name = "T shirt";
  late String brand = "Uniqlo";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
                height: 500,
                width: 500,
                child:
                    Image(image: AssetImage(widget.image), fit: BoxFit.cover)),
            Text("nom: $name"),
            Text("marque: $brand"),
            Text("taille: $size")
          ],
        ),
      ),
    );
  }
}
