import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Transparent TextFormField to create an input field
            TextFormField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '', // Empty hint text since we use RichText above
                contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
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
              style: TextStyle(color: Colors.black), // Text color inside input
            ),

            // Positioned RichText as a hint with differently colored asterisk
            Positioned(
              left: 24.0, // Aligns RichText with TextFormField padding
              top: 12.0, // Adjusts RichText to be vertically centered in field
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
          ],
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
