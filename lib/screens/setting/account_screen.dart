import 'package:aiko_ben_expense_app/screens/navigation.dart';
import 'package:aiko_ben_expense_app/screens/setting/settings.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  AuthService _auth = AuthService();
  final ImagePicker _picker = ImagePicker();
  String? displayName;
  String? avatarText;
  String? photoUrl;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    displayName = _auth.currentUser!.displayName;
    avatarText = displayName!.isNotEmpty ? displayName![0].toUpperCase() : '';
    photoUrl = _auth.currentUser!.photoURL;
    _displayNameController.text = displayName!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Account'),
          automaticallyImplyLeading: true, // Add a back button
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            photoUrl != null ? NetworkImage(photoUrl!) : null,
                        child: photoUrl == null
                            ? Text(
                                avatarText!,
                                style: TextStyle(fontSize: 24),
                              )
                            : null,
                      ),
                      Positioned(
                        right: -12,
                        bottom: -12,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: pickImage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _auth.updateUserProfileName(
                              _displayNameController.text);
                          setState(() {
                            displayName = _displayNameController.text;
                            avatarText = displayName!.isNotEmpty
                                ? displayName![0].toUpperCase()
                                : '';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Username updated')),
                          );
                        }
                      },
                      child: Text('Update Username'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Email: ${_auth.currentUser!.email}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Password: ******',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        //nothing happens now
                        // await _auth.firebaseAuthUser!.updatePassword();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Password reset email sent')),
                        );
                      },
                      child: Text('Forgot Password?'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        // The rest of your AccountPage...
        );
  }
  Future<void> pickImage() async {
    await _auth.updateUserProfilePhotoUrl(null);
  //
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Change this to ImageSource.camera to open the camera
  //   if (pickedFile != null) {
  //     // Upload the image to a storage service like Firebase Storage and get the URL
  //     String? photoURL = null;
  //     // Update the user's photo URL
  //     await _auth.updateUserProfilePhotoUrl(photoURL);
  //     // Update the state to reflect the new photo URL
  //     setState(() {
  //       photoUrl = photoURL;
  //     });
  //   }
  }
}
