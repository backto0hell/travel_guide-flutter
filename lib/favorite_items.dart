import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteItems;

  const FavoritesPage({super.key, required this.favoriteItems});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Избранное'),
        ),
        body: ListView.builder(
          itemCount: widget.favoriteItems.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.favoriteItems[index]['expanded'] =
                            !(widget.favoriteItems[index]['expanded'] ?? false);
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey,
                      child: const Center(child: Text('Фото')),
                    ),
                  ),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Ограничиваем длину названия элемента
                        Expanded(
                          child: Text(
                            widget.favoriteItems[index]['name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              widget.favoriteItems.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        widget.favoriteItems[index]['expanded'] =
                            !(widget.favoriteItems[index]['expanded'] ?? false);
                      });
                    },
                  ),
                  AnimatedCrossFade(
                    firstChild: Container(),
                    secondChild: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(widget.favoriteItems[index]['description']),
                    ),
                    crossFadeState:
                        widget.favoriteItems[index]['expanded'] ?? false
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
