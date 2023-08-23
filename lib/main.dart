import './item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<String>> fetchCategories() async {
    final response =
        await http.get(Uri.parse('https://dummyjson.com/products/categories'));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else {
      throw Exception("failed to fetch data");
    }
  }

  String searchQuery = "";
  String? selectedCategory;
  double minPrice = 0;
  double maxPrice = 1750;
  Future<Map<String, dynamic>> fetchData({String? q}) async {
    final response = await http
        .get(Uri.parse('https://dummyjson.com/products/search?q=$q&limit=100'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("failed to fetch data");
    }
  }

  late Future<List<String>> categories;
  @override
  void initState() {
    super.initState();
    categories = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
      ),
      color: Colors.black,
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  showCursor: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search),
                    label: Text("Search"),
                  ),
                  onChanged: (value) => setState(() {
                    searchQuery = value;
                  }),
                ),
              ),
              FutureBuilder<List<String>>(
                future: categories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Icon(Icons.error);
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Icon(Icons.warning);
                    } else {
                      // Use the categories as needed, e.g., in a dropdown
                      return Row(
                        children: [
                          DropdownButton<String>(
                            hint: const Text("choose category"),
                            items: snapshot.data!
                                .map((e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                            value: selectedCategory,
                          ),
                          IconButton(
                            splashRadius: 4,
                            onPressed: () => setState(() {
                              selectedCategory = null;
                            }),
                            icon: const Icon(Icons.cancel),
                          ),
                        ],
                      );
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              Slider(
                divisions: 1750,
                label: "Minimum Price",
                activeColor: Colors.blueGrey,
                inactiveColor: Colors.red,
                value: minPrice,
                onChanged: (value) {
                  setState(() {
                    minPrice = value;
                  });
                },
                min: 0,
                max: 1750,
              ),
              Slider(
                divisions: 1750,
                label: "Max Price",
                activeColor: Colors.blueGrey,
                inactiveColor: Colors.red,
                value: maxPrice,
                onChanged: (value) {
                  setState(() {
                    maxPrice = value;
                  });
                },
                min: 0,
                max: 1750,
              ),
              Text("$minPrice<price<$maxPrice"),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: fetchData(q: searchQuery),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData ||
                snapshot.data!.isEmpty ||
                !snapshot.data!.containsKey("products")) {
              return const Center(child: Text('No products found.'));
            } else {
              var products = snapshot.data!["products"] as List<dynamic>;
              List<dynamic> filteredProducts = products.where((product) {
                if (selectedCategory == null) {
                  return product["price"] >= minPrice &&
                      product["price"] <=
                          maxPrice; // include all products if no category is selected
                } else {
                  return product['category'] == selectedCategory &&
                      product["price"] >= minPrice &&
                      product["price"] <=
                          maxPrice; // or whatever the condition is
                }
              }).toList();
              return GridView.builder(
                  scrollDirection: Axis.vertical,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent:
                          0.34 * MediaQuery.of(context).size.width,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 40),
                  itemCount: filteredProducts.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return Item(filteredProducts[index]);
                  });
            }
          },
        ),
      ),
    );
  }
}
