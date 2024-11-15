import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:verifyone/core/models/user_models.dart';
import 'package:verifyone/core/utils/constants/colors.dart';
import 'package:verifyone/core/utils/constants/widgets_screens.dart';
import 'package:verifyone/core/view_models/porviders/main_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    MainProvider mainprovider =
        Provider.of<MainProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      mainprovider.fetchUsers();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bttnblack,
        elevation: 1,
        leading: Icon(
          Icons.location_on,
          color: AppColors.white,
        ),
        title: Text(
          "Nilambur",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      floatingActionButton:
          Consumer<MainProvider>(builder: (context, pro, child) {
        return FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () {
            pro.cleartextfield();
            _showAddUserDialog(context);
          },
          backgroundColor: Colors.black,
          child: Icon(Icons.add, color: Colors.white),
        );
      }),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<MainProvider>(
              builder: (context, pro, child) {
                return TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: InkWell(
                        onTap: () {
                          _sortingPopup(context);
                        },
                        child: Icon(Icons.sort)),
                    hintText: pro.currentHintText,
                    hintStyle: TextStyle(
                      color: AppColors.bttnblack,
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: AppColors.bttnblack, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: AppColors.bttnblack, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.blue, width: 1),
                    ),
                  ),
                  style: TextStyle(color: AppColors.textblack),
                  onChanged: (value) {
                    // Filter users when the search text changes
                    pro.filterUsers(value);
                  },
                );
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "User Lists",
              style: TextStyle(
                  fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: Consumer<MainProvider>(
                builder: (context, pro, child) {
                  return ListView.builder(
                    itemCount: pro.filteredUsersList.length + 1,
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (index == pro.filteredUsersList.length) {
                        return Center(
                          child: ElevatedButton(
                            onPressed: pro.isFetching ? null : pro.fetchUsers,
                            child: pro.isFetching
                                ? CircularProgressIndicator()
                                : Text("Load More"),
                          ),
                        );
                      }

                      // Display each user item
                      AppUser item = pro.filteredUsersList[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          shadowColor: Colors.black.withOpacity(0.1),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tileColor: AppColors.white,
                            leading: CircleAvatar(
                              backgroundColor: AppColors.blue,
                              child: Text(
                                item.name[0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                              radius: 40,
                            ),
                            title: Text(item.name),
                            subtitle: Text(item.number),
                            trailing: Text(
                              "Age: ${item.age}",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
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
                titles("Add A New User", 13),
                SizedBox(height: screenWidth * 0.05),
                SizedBox(height: screenWidth * 0.05),
                Consumer<MainProvider>(builder: (context, pro, child) {
                  return Column(
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
                        controller: pro.nameController,
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
                        controller: pro.ageController,
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
                        controller: pro.numberController,
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
                                if (pro.nameController.text.isNotEmpty &&
                                    pro.ageController.text.isNotEmpty &&
                                    pro.numberController.text.isNotEmpty) {
                                  pro.addUser(context);
                                  Navigator.pop(context);
                                  pro.fetchUsers();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Please fill all fields and select an image"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _AddUserTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required BuildContext context,
    List<TextInputFormatter>? inputFormatter,
    String? Function(String?)? validator,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return TextFormField(
      controller: controller,
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
}

void _sortingPopup(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Consumer<MainProvider>(builder: (context, prov, child) {
              int? tempOption = prov.selectedOption;
              return Container(
                width: screenWidth * 0.8,
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    titles("Sort", 14),
                    RadioListTile<int>(
                      fillColor: WidgetStatePropertyAll(AppColors.blue),
                      title: Text("All"),
                      value: 0,
                      groupValue: tempOption,
                      onChanged: (int? value) {
                        setState(() {
                          prov.selectedOption = value;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      fillColor: WidgetStatePropertyAll(AppColors.blue),
                      title: Text("Age: Younger"),
                      value: 1,
                      groupValue: tempOption,
                      onChanged: (int? value) {
                        setState(() {
                          prov.selectedOption = value;
                        });
                      },
                    ),
                    RadioListTile<int>(
                      fillColor: WidgetStatePropertyAll(AppColors.blue),
                      title: Text("Age: Older"),
                      value: 2,
                      groupValue: tempOption,
                      onChanged: (int? value) {
                        setState(() {
                          prov.selectedOption = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Center(
                        child: ElevatedButton(
                      onPressed: () {
                        String currentQuery = prov.nameController.text;
                        prov.filterUsers(currentQuery);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Apply",
                        style: TextStyle(
                            color: AppColors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    )),
                  ],
                ),
              );
            }),
          );
        },
      );
    },
  );
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
