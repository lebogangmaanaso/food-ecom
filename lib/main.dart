import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:food_ecom/register_screen.dart';
import 'package:food_ecom/food_page.dart';
import 'cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/food_page': (context) => FoodPage(),
        '/cart_screen': (context) => CartScreen(),
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'img/imgcolld.jpg',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: LoginForm(),
              ),
              SizedBox(height: 10.0), // Add 10 pixels margin
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Image
          Image.asset(
            'img/imgmild.jpg',
            height: 100.0,
            width: 100.0,
          ),
          SizedBox(height: 20.0),
          // Email Field
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10.0),
          // Password Field
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20.0),
          // Login Button
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    await _signInWithEmailAndPassword(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                  },
            child: _isLoading ? CircularProgressIndicator() : Text('Login'),
          ),
        ],
      ),
    );
  }

  // Function to sign in with email and password
  Future<void> _signInWithEmailAndPassword(
      String email, String password) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (email.isEmpty || password.isEmpty) {
        throw 'Email and password cannot be empty';
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('User signed in successfully');
      // Add navigation or other actions after successful login
      Navigator.pushReplacementNamed(context, '/food_page');
      // Reset form and loading state
      _resetForm();
    } catch (e) {
      print('Error signing in: $e');

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
    _emailController.clear();
    _passwordController.clear();
  }

  // Function to handle Firebase authentication errors
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Invalid password';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed';
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
