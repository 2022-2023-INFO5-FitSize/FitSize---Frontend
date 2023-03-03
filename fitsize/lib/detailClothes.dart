import 'package:flutter/material.dart';

class DetailClothesPage extends StatefulWidget {
  final int idUser;

  const DetailClothesPage({super.key, required this.idUser});

  @override
  State<DetailClothesPage> createState() => _DetailsCLothesState();
}

class _DetailsCLothesState extends State<DetailClothesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail"),
      ),
      body: Center(
        child: Text('You clicked on item with ID ${widget.idUser}'),
      ),
    );
  }
}
