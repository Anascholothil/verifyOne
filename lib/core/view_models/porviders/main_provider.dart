import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verifyone/core/models/user_models.dart';

class MainProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;






  // TextEditingControllers for managing text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  TextEditingController get nameController => _nameController;
  TextEditingController get ageController => _ageController;
  TextEditingController get phoneController => _phoneController;

  // Method to add user to Firestore
  Future<void> addUser(BuildContext context) async {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;
    final phoneNumber = _phoneController.text;

    if (name.isEmpty || phoneNumber.isEmpty || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill all fields correctly!"),
      ));
      return;
    }

    try {
      final newUser = Userdetails(
        name: name,
        age: age,
        phoneNumber: phoneNumber,
      );

      await _firestore.collection('users').add({
        'name': newUser.name,
        'age': newUser.age,
        'phoneNumber': newUser.phoneNumber,
      });

      // Clear the text controllers after saving the user
      _nameController.clear();
      _ageController.clear();
      _phoneController.clear();

      notifyListeners(); // Updates listeners after adding to Firestore
    } catch (error) {
      if (kDebugMode) {
        print("Failed to add user: $error");
      }
    }
  }

  // Method to get users from Firestore
  Future<List<Userdetails>> getUsers() async {
    final querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs
        .map((doc) => Userdetails(
              name: doc['name'],
              age: doc['age'],
              phoneNumber: doc['phoneNumber'],
            ))
        .toList();
  }

  // Dispose controllers when no longer needed
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  ///search bar dynamic

  final List<String> hintTexts = ["Search by name..", "Search by age..", "Search by phone.."];
  int currentHintIndex = 0;

  String get currentHintText => hintTexts[currentHintIndex];

  MainProvider() {
    _startHintTextRotation();
  }

  void _startHintTextRotation() {
    Future.delayed(const Duration(seconds: 4), () {
      currentHintIndex = (currentHintIndex + 1) % hintTexts.length;
      notifyListeners();  // Notifying listeners (UI updates)
      _startHintTextRotation();  // Continue the rotation
    });
  }

  String userImageUrl = '';
  File? userImageFile;

  Future<void> pickUserImageFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      await cropUserImage(pickedImage.path);
    } else {
      print('No image selected.');
    }
  }

  Future<void> pickUserImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      await cropUserImage(pickedImage.path);
    } else {
      print('No image selected.');
    }
  }

  Future<void> cropUserImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatioPresets: Platform.isAndroid
          ? [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ]
          : [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.white,
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedFile != null) {
      userImageFile = File(croppedFile.path);
      notifyListeners(); // Update the UI only after setting the image
    }
  }
}



