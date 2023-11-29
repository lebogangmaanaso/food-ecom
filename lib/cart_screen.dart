// cart_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  DatabaseReference _cartRef =
      FirebaseDatabase.instance.reference().child('cart');
  List<Map<String, dynamic>> cartItems = [];
  int totalQuantity = 1;

  FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    retrieveCartItems();
    retrieveUser();
  }

  void retrieveUser() {
    _user = _auth.currentUser;
  }

  void retrieveCartItems() async {
    DataSnapshot dataSnapshot =
        await _cartRef.child(_auth.currentUser!.uid).get();

    if (dataSnapshot.value != null) {
      Map<String, dynamic> cartItemsDynamic =
          dataSnapshot.value as Map<String, dynamic>;

      setState(() {
        cartItems =
            cartItemsDynamic.values.toList().cast<Map<String, dynamic>>();
      });
    }
  }

  double calculateTotalPrice() {
    double total = 0;

    for (var item in cartItems) {
      double price = double.tryParse(item['price'].toString()) ?? 0;
      int quantity = item['quantity'] ?? 1;

      total += price * quantity;
    }

    return total;
  }

  void incrementQuantity() {
    setState(() {
      totalQuantity++;
    });
  }

  void deleteItem(int index) {
    // Delete the item from the Realtime Database
    String itemKey = cartItems[index]['key'];
    _cartRef.child(itemKey).remove();

    // Remove the item locally
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          // Increment Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: incrementQuantity,
              ),
              Text('Quantity: $totalQuantity'),
            ],
          ),
          // List of Items
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 10,
                  shadowColor: Colors.grey,
                  child: ListTile(
                    title: Text(cartItems[index]['name']),
                    subtitle: Text('Price: ${cartItems[index]['price']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteItem(index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Total Price
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Price: \$${calculateTotalPrice().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
