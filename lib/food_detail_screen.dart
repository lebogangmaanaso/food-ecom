import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'cart_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> foodItem;

  FoodDetailScreen({required this.foodItem});

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  DatabaseReference _cartRef =
      FirebaseDatabase.instance.reference().child('cart');

  FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    retrieveUser();
  }

  void retrieveUser() {
    _user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Details'),
      ),
      body: Column(
        children: [
          // Centered and increased height image
          Container(
            height: 200,
            child: Image.network(
              widget.foodItem['imgUrl'],
              fit: BoxFit.cover,
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.foodItem['name'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Price: ${widget.foodItem['price']}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Description: ${widget.foodItem['description']}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          // Button at the bottom
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  // Add the item to the Realtime Database
                  _cartRef.child(_auth.currentUser!.uid).push().set({
                    'name': widget.foodItem['name'],
                    'imgUrl': widget.foodItem['imgUrl'],
                    'price': widget.foodItem['price'],
                    'description': widget.foodItem['description'],
                  });

                  // Optionally show a message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item added to the cart.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: Text('Add to Cart'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
