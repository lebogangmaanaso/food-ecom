import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image for Registration Screen
          Image.asset(
            'img/imgBack.jpg', // Replace with the path to your registration screen background image
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Center(
            child: RegisterForm(),
          ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Username Field
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10.0),

          // Email Field for Registration
          TextField(
            controller: _registerEmailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10.0),

          // Password Field for Registration
          TextField(
            controller: _registerPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20.0),

          // Register Button
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    // Call the function to register
                    await _registerUser(
                      _usernameController.text.trim(),
                      _registerEmailController.text.trim(),
                      _registerPasswordController.text.trim(),
                    );
                  },
            child: _isLoading ? CircularProgressIndicator() : Text('Register'),
          ),
        ],
      ),
    );
  }

  // Function to register a user with email and password
  Future<void> _registerUser(
      String username, String email, String password) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        throw 'All fields must be filled';
      }

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add additional logic for user registration, such as saving username
      // to a database or performing other setup tasks.

      print('User registered successfully');

      // Reset form and loading state
      _resetForm();
    } catch (e) {
      print('Error registering user: $e');

      String errorMessage = 'An error occurred';

      if (e is FirebaseAuthException) {
        errorMessage = _handleFirebaseAuthError(e);
      }

      // Display an error message to the user
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to reset form and text controllers
  void _resetForm() {
    _usernameController.clear();
    _registerEmailController.clear();
    _registerPasswordController.clear();
  }

  // Function to handle Firebase authentication errors
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'The account already exists for that email';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Registration failed';
    }
  }

  // Function to display error dialog
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
