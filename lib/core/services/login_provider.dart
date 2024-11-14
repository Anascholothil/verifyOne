import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
 import 'package:verifyone/core/view/screens/authentications/otp_screen.dart';
import 'package:verifyone/core/view/screens/home/home_screen.dart'; // Ensure this is your home screen file

class LoginProviderNew extends ChangeNotifier {
  TextEditingController Loginphnnumber = TextEditingController();
  TextEditingController otpverifycontroller = TextEditingController();

  String VerificationId = "";

  bool _isLoading = false;  // Private variable to track loading state

  bool get isLoading => _isLoading;  // Getter to access the loading state

  // Method to set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  bool loader = false;

  // Clear phone number and OTP fields
  void clearLoginPageNumber() {
    Loginphnnumber.clear();
    otpverifycontroller.clear();
  }

  // Send OTP to the provided phone number
  void sendotp(BuildContext context) async {
    loader = true;
    notifyListeners();
    await auth.verifyPhoneNumber(
      phoneNumber: "+91${Loginphnnumber.text}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.white,
          content: Text("Verification Completed",
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              )),
          duration: Duration(milliseconds: 3000),
        ));
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == "invalid-phone-number") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sorry, Verification Failed"),
            duration: Duration(milliseconds: 3000),
          ));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        VerificationId = verificationId;
        loader = false;
        notifyListeners();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(),
            ));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Color(0xbd380038),
          content: Text("OTP sent to phone successfully",
              style: TextStyle(
                color: Color(0xffffffff),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
          duration: Duration(milliseconds: 3000),
        ));
        log("Verification Id : $verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify the OTP entered by the user
  Future<void> verify(BuildContext context, String enteredOtp) async {
    try {
      loader = true;  // Show loading indicator
      notifyListeners();

      // OTP verification logic goes here (e.g., using Firebase)
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: VerificationId,  // Ensure you have a valid verification ID
        smsCode: enteredOtp,
      );
      await auth.signInWithCredential(credential);  // Sign in with the OTP

      loader = false;  // Hide loading indicator after verification
      notifyListeners();
    } catch (e) {
      loader = false;
      notifyListeners();
      print("Error during OTP verification: $e");
      throw Exception("Verification failed");
    }
  }


}
