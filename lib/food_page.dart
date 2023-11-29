// food_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'food_category_page.dart';
import 'cart_screen.dart';

class FoodPage extends StatefulWidget {
  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  DatabaseReference _foodRef =
      FirebaseDatabase.instance.reference().child('food_categories');
  List<Map<dynamic, dynamic>> foodCategories = [];

  @override
  void initState() {
    super.initState();
    retrieveFoodCategories();
  }

  void retrieveFoodCategories() async {
    DataSnapshot dataSnapshot = await _foodRef.get();

    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> categoriesDynamic =
          dataSnapshot.value as Map<dynamic, dynamic>;

      categoriesDynamic.forEach((key, value) {
        setState(() {
          foodCategories.add({
            'category': key,
            'imgUrl': value['imgUrl'],
            'rating': value['rating'],
            'name': value['name']
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Food Categories'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () async {
              // Navigate to CartScreen
              await Navigator.pushNamed(context, '/cart_screen');

              // Optional: Handle changes after returning from CartScreen
              // For example, you can refresh the FoodPage if needed
              // retrieveFoodCategories();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: foodCategories.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 10,
            shadowColor: Colors.grey,
            child: Container(
              height: 150,
              child: Row(
                children: [
                  // Image
                  Container(
                    height: double.infinity,
                    width: 150, // Fixed width for the image
                    child: Image.network(
                      foodCategories[index]['imgUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center text vertically
                        children: [
                          Text(
                            foodCategories[index]['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              Text(
                                ' ${foodCategories[index]['rating']}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Buy Button
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to FoodCategoryPage and pass the category name
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FoodCategoryPage(
                                    category: foodCategories[index]['category'],
                                  ),
                                ),
                              );
                            },
                            child: Text('Buy'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
