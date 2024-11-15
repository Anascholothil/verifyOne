import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verifyone/core/models/user_models.dart';

class MainProvider with ChangeNotifier {
  /// Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  /// Users data lists
  List<AppUser> usersList = [];
  List<AppUser> filteredUsersList = [];
  DocumentSnapshot? lastDocument;

  /// Loading states
  bool isFetching = false;
  int? selectedOption = 0;

  /// Hint text rotation setup
  final List<String> hintTexts = ["Search by name..", "Search by age..", "Search by phone.."];
  int currentHintIndex = 0;

  /// User image variables
  String userImageUrl = '';
  File? userImageFile;

  MainProvider() {
    _startHintTextRotation();
    fetchUsers();
  }

  /// Fetch users from Firestore
  Future<void> fetchUsers() async {
    if (isFetching) return;
    isFetching = true;
    try {
      QuerySnapshot querySnapshot;
      if (lastDocument == null) {
        querySnapshot = await _firestore.collection("USERS").limit(10).get();
      } else {
        querySnapshot = await _firestore
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

  /// Add user to Firestore
  Future<void> addUser(BuildContext context) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    HashMap<String, dynamic> map = HashMap();
    map["USER_ID"] = id;
    map["NAME"] = nameController.text;
    map["AGE"] = ageController.text;
    map["NUMBER"] = numberController.text;

    try {
      await _firestore.collection("USERS").doc(id).set(map);
      _showSnackbar(context, "Successfully Added", Colors.black);
    } catch (e) {
      _showSnackbar(context, "Failed to add user. Please try again.", Colors.red);
    }
    notifyListeners();
  }

  /// Filter users based on keyword and selected options
  Future<void> filterUsers(String query) async {
    if (query.isEmpty) {
      filteredUsersList = List.from(usersList);
    } else {
      filteredUsersList = usersList.where((user) =>
      user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.number.toLowerCase().contains(query.toLowerCase())).toList();
    }
    sortUsersByAge(selectedOption);
    notifyListeners();
  }

  /// Update selected sorting option
  void updateSelectedOption(int option) {
    selectedOption = option;
    notifyListeners();
  }

  /// Sort users by age
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

  /// Clear input Method
  void clearTextFields() {
    nameController.clear();
    ageController.clear();
    numberController.clear();
  }

  /// Start hint text rotation
  void _startHintTextRotation() {
    Future.delayed(const Duration(seconds: 4), () {
      currentHintIndex = (currentHintIndex + 1) % hintTexts.length;
      notifyListeners();
      _startHintTextRotation();
    });
  }

  /// Pick  image from gallery and crop
  Future<void> pickUserImageFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      await cropUserImage(pickedImage.path);
    } else {
      print('No image selected.');
    }
  }

  /// Pick  image from camera and crop
  Future<void> pickUserImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      await cropUserImage(pickedImage.path);
    } else {
      print('No image selected.');
    }
  }

  /// Crop  image
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
      notifyListeners();
    }
  }

  // Display a snackbar
  void _showSnackbar(BuildContext context, String message, Color color) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            backgroundColor: color,
          ),
        );
      }
    });
  }

  String get currentHintText => hintTexts[currentHintIndex];
}
