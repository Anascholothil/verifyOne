import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:verifyone/core/view/screens/authentications/otp_screen.dart';

class LoginProviderNew extends ChangeNotifier {


  /// Controllers
  final TextEditingController Loginphnnumber = TextEditingController();
  final TextEditingController otpverifycontroller = TextEditingController();

  // Firebase Instances
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  /// Variables
  String VerificationId = "";
  bool _isLoading = false;
  bool loader = false;



  bool get isLoading => _isLoading;

  ///  Loader Methods

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearLoginPageNumber() {
    Loginphnnumber.clear();
    otpverifycontroller.clear();
  }

  /// Authentication Methods

  void sendotp(BuildContext context) async {
    loader = true;
    notifyListeners();

    await auth.verifyPhoneNumber(
      phoneNumber: "+91${Loginphnnumber.text}",
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _handleVerificationCompleted(context, credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        _handleVerificationFailed(context, e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _handleCodeSent(context, verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle auto retrieval timeout if needed
      },
    );
  }

  Future<void> verify(BuildContext context, String enteredOtp) async {
    try {
      _setVerificationLoading(true);
      await _performOtpVerification(enteredOtp);
      _setVerificationLoading(false);
    } catch (e) {
      _handleVerificationError(e);
    }
  }

  ///Verification Method

  Future<void> _handleVerificationCompleted(
      BuildContext context,
      PhoneAuthCredential credential,
      ) async {
    await auth.signInWithCredential(credential);
    _showSnackBar(
      context,
      "Verification Completed",
      backgroundColor: Colors.white,
      textColor: Colors.red,
      fontSize: 20,
      fontWeight: FontWeight.w800,
    );
  }

  void _handleVerificationFailed(BuildContext context, FirebaseAuthException e) {
    if (e.code == "invalid-phone-number") {
      _showSnackBar(
        context,
        "Sorry, Verification Failed",
        duration: const Duration(milliseconds: 3000),
      );
    }
  }

  void _handleCodeSent(BuildContext context, String verificationId) {
    VerificationId = verificationId;
    loader = false;
    notifyListeners();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OtpScreen()),
    );

    _showSnackBar(
      context,
      "OTP sent to phone successfully",
      backgroundColor: const Color(0xbd380038),
      textColor: const Color(0xffffffff),
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );

    log("Verification Id : $verificationId");
  }

  Future<void> _performOtpVerification(String enteredOtp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: VerificationId,
      smsCode: enteredOtp,
    );
    await auth.signInWithCredential(credential);
  }

  void _setVerificationLoading(bool loading) {
    loader = loading;
    notifyListeners();
  }

  void _handleVerificationError(dynamic error) {
    loader = false;
    notifyListeners();
    print("Error during OTP verification: $error");
    throw Exception("Verification failed");
  }

  /// Snack PopUP

  void _showSnackBar(
      BuildContext context,
      String message, {
        Color backgroundColor = Colors.black,
        Color textColor = Colors.white,
        double fontSize = 14,
        FontWeight fontWeight = FontWeight.normal,
        Duration duration = const Duration(milliseconds: 3000),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
        duration: duration,
      ),
    );
  }
}