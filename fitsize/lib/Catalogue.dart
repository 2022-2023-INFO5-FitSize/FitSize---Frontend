import 'package:flutter/material.dart';

import 'detailClothes.dart';

class CataloguePage extends StatefulWidget {
  final List<String> imageUrls;

  const CataloguePage({super.key, required this.imageUrls});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  late PageController _pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Catalogue',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            )),
        body: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          children: List.generate(widget.imageUrls.length, (index) {
            return SizedBox(
              height: 200,
              width: 200,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailClothesPage(image: widget.imageUrls[index]),
                    ),
                  );
                },
                child: Image(
                  image: AssetImage(widget.imageUrls[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
        ));
  }
}
