import 'package:flutter/material.dart';
import 'supabase_client.dart';
import 'dart:math';
import 'favorite_items.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Справочник путешественника',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedCity;
  int? selectedCategory;
  List<String> cities = [];
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> favoriteItems = [];
  List<String> categories = [
    'Музей',
    'Место',
    'Событие',
    'Достопримечательность'
  ];

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    final response = await supabase.from('cities').select('id, name').execute();
    if (response.error == null) {
      final data = response.data as List<dynamic>;
      setState(() {
        cities = data.map<String>((city) => city['name'] as String).toList();
      });
      print('Cities: $data');
    } else {
      print('Error fetching cities: ${response.error!.message}');
    }
  }

  Future<void> fetchItems(int cityId) async {
    final response = await supabase
        .from('items')
        .select('id, name, description, categories!inner(id, city_id)')
        .eq('categories.city_id', cityId)
        .execute();
    if (response.error == null) {
      final data = response.data as List<dynamic>;
      setState(() {
        items = data
            .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
            .toList();
        filteredItems = items;
        items.shuffle(Random());
      });
      print('Items: $data');
    } else {
      print('Error fetching items: ${response.error!.message}');
    }
  }

  void filterItemsByCategory(String category) {
    setState(() {
      selectedCategory = categories.indexOf(category) + 1;
      if (selectedCity == 'Санкт-Петербург') {
        filteredItems = items.where((item) {
          // Для Санкт-Петербурга id категорий от 5 до 8
          return item['categories']['id'] == selectedCategory! + 4;
        }).toList();
      } else {
        filteredItems = items.where((item) {
          // Для других городов используем стандартную фильтрацию по категориям
          return item['categories']['id'] == selectedCategory;
        }).toList();
      }
    });
  }

  // Функция для добавления/удаления элемента в избранное
  void toggleFavorite(Map<String, dynamic> item) {
    setState(() {
      if (favoriteItems.contains(item)) {
        favoriteItems.remove(item);
      } else {
        favoriteItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Guide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FavoritesPage(favoriteItems: favoriteItems)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            hint: const Text('Выберите город'),
            value: selectedCity,
            onChanged: (newValue) {
              setState(() {
                selectedCity = newValue;
                fetchItems(cities.indexOf(newValue!) +
                    1); // Загрузка элементов для выбранного города
              });
            },
            items: cities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
          ),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      filterItemsByCategory(
                          category); // Фильтрация элементов по выбранной категории
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          selectedCategory == categories.indexOf(category) + 1
                              ? Colors.white
                              : Colors.black,
                      backgroundColor:
                          selectedCategory == categories.indexOf(category) + 1
                              ? const Color.fromARGB(255, 41, 41, 41)
                              : const Color.fromARGB(255, 201, 201, 201),
                      minimumSize: const Size(80, 40),
                    ),
                    child: Text(category),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            filteredItems[index]['expanded'] =
                                !(filteredItems[index]['expanded'] ?? false);
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          color: const Color.fromARGB(255, 224, 224, 224),
                          child: const Center(child: Text('Фото')),
                        ),
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                filteredItems[index]['name'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                favoriteItems.contains(filteredItems[index])
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    favoriteItems.contains(filteredItems[index])
                                        ? Colors.red
                                        : null,
                              ),
                              onPressed: () {
                                toggleFavorite(filteredItems[
                                    index]); // Добавление/удаление элемента в избранное
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            filteredItems[index]['expanded'] =
                                !(filteredItems[index]['expanded'] ?? false);
                          });
                        },
                      ),
                      AnimatedCrossFade(
                        firstChild: Container(),
                        secondChild: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(filteredItems[index]['description']),
                        ),
                        crossFadeState:
                            filteredItems[index]['expanded'] ?? false
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
