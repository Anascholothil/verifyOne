import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verifyone/core/utils/constants/colors.dart';
import 'package:verifyone/core/utils/constants/widgets_screens.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});

  // Define a GlobalKey for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.bgwhite,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth / 15, vertical: screenHeight / 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center the image at the top of the screen
              Align(
                alignment: Alignment.topCenter,
                child: Image(
                  image: AssetImage('assets/otpimg.png'),
                  width: screenWidth / 2,
                  height: screenHeight / 5,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight / 15), // Adds spacing before the title
              titles('Enter Phone Number', 15), // Assuming titles is a custom widget
          
               SizedBox(height: screenHeight/28), // Space between label and TextFormField
          
              // Form for validating phone number
              Form(
                key: _formKey,
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(10),   // Limit to 10 digits
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number *',
                    hintStyle: TextStyle(color: Colors.grey,fontSize: 11,fontWeight: FontWeight.w300),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0), // Curved edges
                      borderSide: BorderSide(color: Colors.grey, width: .7), // Reduced border width
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey, width: .7), // Reduced border width
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.blue, width: .7), // Reduced border width
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (value.length != 10) {
                      return 'Phone number must be exactly 10 digits';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: screenHeight/60,
              ),
              // RichText with terms and conditions
              Padding(
                padding:  EdgeInsets.only(left: 20),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: AppColors.txtgrey, fontSize: 11,), // Default text style
                    children: [
                      TextSpan(text: 'By Continuing, I agree to TotalX’s'),
                      TextSpan(
                        text: ' Terms and Conditions ',
                        style: TextStyle(color: Colors.blue),
                      ),
                      TextSpan(text: '& '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
          
              const SizedBox(height: 20.0), // Space after the text
              // Submit Button
              Center(
                child: SizedBox(
                  width: screenWidth/1.2,
                  height: screenHeight/17,
                  child: ElevatedButton(

                    onPressed: () {
                      // Trigger form validation
                      if (_formKey.currentState?.validate() ?? false) {
                        // If valid, proceed with the next step or show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Phone number is valid')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.bttnblack, // Text color
                    ),
                    child: Text('Get OTP',style: TextStyle(
                      color: AppColors.white,
                    ),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
