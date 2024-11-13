import 'package:flutter/material.dart';
import 'package:verifyone/core/utils/constants/colors.dart';
import 'package:verifyone/core/utils/constants/widgets_screens.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: screenHeight/15,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Image(
              image: AssetImage('assets/logimg.png'),
              width: screenWidth / 2,
              height: screenHeight / 5,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: screenHeight / 15), // Adds spacing before the title
          Padding(
            padding:  EdgeInsets.only(left: screenWidth/17),
            child: titles('OTP Verification', 15),
          ),
          SizedBox(height: screenHeight / 30), // Adds spacing before the title

          Padding(
            padding:  EdgeInsets.symmetric(horizontal: screenWidth/20),
            child: Text('Enter the verification code we just sent to your number +91 *******21.',style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400,color: Colors.black54),),
          ),

      ],),

    );
  }
}
