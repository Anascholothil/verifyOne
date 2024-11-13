import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter your phone number *',
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0), // Spacing between icon and text
              child: RichText(
                text: TextSpan(
                  text: 'Enter your phone number ',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red), // Asterisk in red
                    ),
                  ],
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0), // Curved edges
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}
