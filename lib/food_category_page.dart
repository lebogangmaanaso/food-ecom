import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'food_detail_screen.dart'; // Import the new detail screen

class FoodCategoryPage extends StatefulWidget {
  final String category;

  FoodCategoryPage({required this.category});

  @override
  _FoodCategoryPageState createState() => _FoodCategoryPageState();
}

class _FoodCategoryPageState extends State<FoodCategoryPage> {
  DatabaseReference _foodRef =
      FirebaseDatabase.instance.reference().child('food_categories');
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    retrieveFoodItems();
  }

  void retrieveFoodItems() async {
    DataSnapshot dataSnapshot = await _foodRef.get();

    if (dataSnapshot.value != null) {
      Map<dynamic, dynamic> categoryData =
          dataSnapshot.value as Map<dynamic, dynamic>;

      if (categoryData.containsKey(widget.category)) {
        // Get the category details
        Map<dynamic, dynamic> categoryDetails = categoryData[widget.category];

        // Check if the category has items
        if (categoryDetails.containsKey(widget.category)) {
          List<dynamic> itemsDynamic =
              categoryDetails[widget.category] as List<dynamic>;

          itemsDynamic.forEach((item) {
            if (item != null) {
              setState(() {
                foodItems.add({
                  'name': item['name'],
                  'imgUrl': item['imgUrl'],
                  'price': item['price'],
                  'description': item['description'],
                });
              });
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Category: ${widget.category}'),
      ),
      body: ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 10,
            shadowColor: Colors.grey,
            child: ListTile(
              title: Text(foodItems[index]['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: \$${foodItems[index]['price']}'),
                  Text('Description: ${foodItems[index]['description']}'),
                ],
              ),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(foodItems[index]['imgUrl']),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // Navigate to FoodDetailScreen with the selected food item
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailScreen(
                        foodItem: foodItems[index],
                      ),
                    ),
                  );
                },
                child: Text('Buy'),
              ),
            ),
          );
        },
      ),
    );
  }
}
