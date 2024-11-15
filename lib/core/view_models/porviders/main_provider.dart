import 'dart:collection';
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

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  List<AppUser> usersList = [];
  List<AppUser> filteredUsersList = [];
  DocumentSnapshot? lastDocument;

  bool isFetching = false;
  Future<void> addUser(BuildContext context) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    HashMap<String, dynamic> map = HashMap();
    map["USER_ID"] = id;

    map["NAME"] = nameController.text;
    map["AGE"] = ageController.text;
    map["NUMBER"] = numberController.text;

    try {
      await FirebaseFirestore.instance.collection("USERS").doc(id).set(map);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Successfully Added"),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xda4b4b4b),
            ),
          );
        }
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add user. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    notifyListeners();
  }
  Future<void> fetchUsers() async {
    if (isFetching) return;
    isFetching = true;

    try {
      QuerySnapshot querySnapshot;
      if (lastDocument == null) {
        querySnapshot = await FirebaseFirestore.instance.collection("USERS").limit(10).get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection("USERS")
            .startAfterDocument(lastDocument!)
            .limit(10)
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        usersList.addAll(querySnapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
        lastDocument = querySnapshot.docs.last;
        filteredUsersList = List.from(usersList);
      }

      notifyListeners();
    } catch (e) {
      print("Error in fetchUsers: $e");
    } finally {
      isFetching = false;
    }
  }

  int? selectedOption = 0;
  void updateSelectedOption(int option) {
    selectedOption = option;
    notifyListeners();
  }

  Future<void> filterUsers(String query) async {
    // First, filter users by the search query (name or number)
    if (query.isEmpty) {
      filteredUsersList = List.from(usersList);
    } else {
      filteredUsersList = usersList
          .where((user) =>
      user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.number.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    sortUsersByAge(selectedOption);

    print("Filtered and sorted users: ${filteredUsersList.length}");
    notifyListeners();
  }

  ///search bar dynamic

  final List<String> hintTexts = ["Search by name..", "Search by age..", "Search by phone.."];
  int currentHintIndex = 0;

  String get currentHintText => hintTexts[currentHintIndex];

  MainProvider() {
    _startHintTextRotation();
    fetchUsers();
  }

  /// sort pop
  void sortUsersByAge(int? selectedOption) {
    switch (selectedOption) {
      case 1: // Younger (below 60)
        filteredUsersList = filteredUsersList.where((user) => int.parse(user.age) < 60).toList();
        break;
      case 2: // Older (60 and above)
        filteredUsersList = filteredUsersList.where((user) => int.parse(user.age) >= 60).toList();
        break;
      default: // All
        break;
    }
  }

/// clear Function
  void cleartextfield (){
    nameController.clear();
    ageController.clear();
    numberController.clear();
  }
///hint rotation
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



