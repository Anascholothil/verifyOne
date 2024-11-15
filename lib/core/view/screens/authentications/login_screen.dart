import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verifyone/core/services/login_provider.dart';
import 'package:verifyone/core/utils/constants/colors.dart';
import 'package:verifyone/core/utils/constants/widgets_screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth / 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight / 17),
              _buildLogo(screenHeight, screenWidth),
              SizedBox(height: screenHeight / 15),
              _buildTitle(),
              SizedBox(height: screenHeight / 28),
              _buildPhoneNumberForm(context),
              SizedBox(height: screenHeight / 60),
              _buildTermsAndConditions(),
              const SizedBox(height: 20.0),
              _buildOtpButton(screenHeight, screenWidth, context),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo widget
  Widget _buildLogo(double screenHeight, double screenWidth) {
    return Align(
      alignment: Alignment.topCenter,
      child: Image.asset(
        'assets/otpimg.png',
        width: screenWidth / 2,
        height: screenHeight / 5,
        fit: BoxFit.contain,
      ),
    );
  }

  // Title widget
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: titles('Enter Phone Number', 14),
    );
  }

  /// Phone number input field widget
  Widget _buildPhoneNumberForm(BuildContext context) {
    final loginProvider = Provider.of<LoginProviderNew>(context);
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: loginProvider.Loginphnnumber,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          hintText: 'Enter your phone number *',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w300,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 20.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey, width: 0.7),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.grey, width: 0.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide(color: Colors.blue, width: 0.7),
          ),
        ),
        style: TextStyle(color: AppColors.textblack),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your phone number';
          } else if (value.length != 10) {
            return 'Please enter 10 digits';
          }
          return null;
        },
      ),
    );
  }

  /// Terms and conditions widget
  Widget _buildTermsAndConditions() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: AppColors.textblack, fontSize: 12),
          children: [
            TextSpan(text: 'By Continuing, I agree to TotalX’s '),
            TextSpan(
              text: 'Terms and Conditions ',
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
    );
  }

  /// OTP button widget
  Widget _buildOtpButton(double screenHeight, double screenWidth, BuildContext context) {
    return Consumer<LoginProviderNew>(
      builder: (context, loginProvider, child) {
        return Center(
          child: TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                loginProvider.sendotp(context);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.bttnblack,
              fixedSize: Size(screenWidth / 1.2, screenHeight / 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            child: loginProvider.isLoading
                ? CircularProgressIndicator(color: AppColors.white)
                : Text(
              'Get OTP',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        );
      },
    );
  }
}
