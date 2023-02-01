import 'package:flutter/material.dart';

class CataloguePage extends StatefulWidget {
  CataloguePage({Key? key}) : super(key: key);

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 227, 227, 227),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text('Catalogue Page'),
        ),
      ),
    );
  }
}
