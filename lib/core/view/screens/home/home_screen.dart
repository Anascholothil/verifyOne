import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verifyone/core/utils/constants/colors.dart';
import 'package:verifyone/core/utils/constants/widgets_screens.dart';
import 'package:verifyone/core/view_models/porviders/main_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const Icon(Icons.location_on, color: Colors.white),
        title: const Text(
          "Mannarkkad",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "User Lists",
              style: TextStyle(
                  fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      shadowColor: Colors.black.withOpacity(0.1),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(screenWidth * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tileColor: Colors.white,
                        leading: CircleAvatar(
                          backgroundImage: const AssetImage("assets/otp.png"),
                          radius: screenWidth * 0.08,
                        ),
                        title: const Text("User Name"),
                        subtitle: const Text("Age: 33"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.width;
    final provider = Provider.of<MainProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: provider
              .currentHintText, // Access currentHintText from MainProvider
          hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              // Add filter action
              _sortingPopup(context);
            },
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.03,
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: screenWidth * 0.8,
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titles("Add A New User", 14),
                SizedBox(height: screenWidth * 0.05),
                Consumer<MainProvider>(
                  builder: (context, pro, child) {
                    return GestureDetector(
                      onTap: () {
                        showBottomSheet(context);
                      },
                      child: Center(
                        child: Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: ClipOval(
                            child: pro.userImageFile != null
                                ? Image.file(
                                    pro.userImageFile!,
                                    fit: BoxFit.cover,
                                    width: screenWidth * 0.2,
                                    height: screenWidth * 0.2,
                                  )
                                : Image.asset(
                                    'assets/addUser.png',
                                    fit: BoxFit.cover,
                                    width: screenWidth * 0.2,
                                    height: screenWidth * 0.2,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenWidth * 0.05),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _AddUserTextField(
                        labelText: "Name",
                        context: context,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      _AddUserTextField(
                        labelText: "Age",
                        keyboardType: TextInputType.number,
                        context: context,
                        inputFormatter: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter age';
                          }
                          if (value.length != 2) {
                            return 'Age must be a 2-digit number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      _AddUserTextField(
                        labelText: "Phone Number",
                        keyboardType: TextInputType.phone,
                        context: context,
                        inputFormatter: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenWidth * 0.05),
                      Row(
                        children: [
                          Expanded(
                            child: _Buttons(
                              context,
                              label: "Cancel",
                              color: Colors.grey[300]!,
                              textColor: Colors.grey,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: _Buttons(
                              context,
                              label: "Save",
                              color: Colors.blue,
                              textColor: Colors.white,
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _AddUserTextField({
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    required BuildContext context,
    List<TextInputFormatter>? inputFormatter,
    String? Function(String?)? validator,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return TextFormField(
      keyboardType: keyboardType,
      inputFormatters: inputFormatter,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey,
          fontSize: screenWidth * 0.04,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.02,
          horizontal: screenWidth * 0.05,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      validator: validator,
    );
  }

  Widget _Buttons(BuildContext context,
      {required String label,
      required Color color,
      required Color textColor,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * 0.03),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: textColor),
      ),
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      context: context,
      builder: (BuildContext bc) {
        return Consumer<MainProvider>(builder: (context, value, child) {
          return Container(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      await value.pickUserImageFromGallery();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading:
                          Icon(Icons.image, color: AppColors.blue, size: 25),
                      title: Text("Gallery",
                          style:
                              TextStyle(color: AppColors.blue, fontSize: 20)),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await value.pickUserImageFromCamera();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading:
                          Icon(Icons.camera, color: AppColors.blue, size: 25),
                      title: Text("Camera",
                          style:
                              TextStyle(color: AppColors.blue, fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _sortingPopup(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Add a variable to track the selected sorting option
    int? selectedOption = 0; // 0 for All, 1 for Younger, 2 for Older

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: screenWidth * 0.8,
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    titles("Sort", 12),
                    RadioListTile<int>(
                      fillColor: WidgetStatePropertyAll(AppColors.blue),
                      title: Text("All"),
                      value: 0,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      fillColor: WidgetStatePropertyAll(AppColors.blue),
                      title: Text("Age: Younger"),
                      value: 1,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      fillColor: WidgetStatePropertyAll(AppColors.blue),
                      title: Text("Age: Older"),
                      value: 2,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Center(
                        child: _Buttons(context,
                            label: "Apply",
                            color: AppColors.blue,
                            textColor: AppColors.white, onPressed: () {
                      Navigator.pop(context);
                    }))
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

///my add user
// void _showAddUserDialog(BuildContext context) {
//   final screenWidth = MediaQuery.of(context).size.width;
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           width: screenWidth * 0.8,
//           padding: EdgeInsets.all(screenWidth * 0.05),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Add A New User",
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.05,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: screenWidth * 0.05),
//               Form(
//                 child: Column(
//                   children: [
//                     // Name field
//                     TextFormField(
//                       controller: Provider.of<MainProvider>(context).nameController,
//                       decoration: InputDecoration(labelText: "Name"),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a name';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: screenWidth * 0.03),
//                     // Age field
//                     TextFormField(
//                       controller: Provider.of<MainProvider>(context).ageController,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(2),
//                       ],
//                       decoration: InputDecoration(labelText: "Age"),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter age';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: screenWidth * 0.03),
//                     // Phone field
//                     TextFormField(
//                       controller: Provider.of<MainProvider>(context).phoneController,
//                       keyboardType: TextInputType.phone,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(10),
//                       ],
//                       decoration: InputDecoration(labelText: "Phone Number"),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter phone number';
//                         }
//                         if (value.length != 10) {
//                           return 'Phone number must be 10 digits';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: screenWidth * 0.05),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text("Cancel"),
//                           ),
//                         ),
//                         SizedBox(width: screenWidth * 0.02),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               final provider = Provider.of<MainProvider>(context, listen: false);
//                               provider.addUser(context);
//                               Navigator.pop(context); // Close the dialog
//                             },
//                             child: Text("Save"),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
