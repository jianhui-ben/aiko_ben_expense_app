import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/database.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String emailErrorText = "The email can't be empty";
  final String passwordErrorText =
      'The password has to be longer than 5 characters';
  String _errorText = '';
  bool loading = false;

  Future<void> signUpWithEmailAndPassword() async {
    final String email = emailController.text;
    final String password = passwordController.text;
    final String useName = userNameController.text;

    dynamic result =
        await _auth.registerWithEmailAndPassword(email, password, useName);
    if (result is! User?) {
      setState(() {
        _errorText = result;
      });
    } else {
      _errorText = '';
      print("user signed up and logged in successfully");
      print("email: $email, password: $password, userId: $result");
    }

    // Save the default user settings to Firestore setting collections
    await DatabaseService(uid: result.uid).addDefaultSetting(useName);
  }

  @override
  Widget build(BuildContext context) {
    bool showEmailAndPasswordError = false;

    return loading
        ? Loading()
        : Scaffold(
            body: Stack(
            children: [
              // Positioned image at the bottom right
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Opacity(
                  opacity: 0.4, // Adjust the opacity as needed
                  child: Image.asset('assets/images/finance_pig.jpg'),
                ),
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 50),
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Text(
                          "Register",
                          style: appNameTextStyle,
                        ),
                      ),
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: ListView(children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return emailErrorText;
                                  }
                                  return null;
                                },
                                decoration: textInputDecoration.copyWith(
                                  labelText: 'Email',
                                  errorText: showEmailAndPasswordError
                                      ? emailErrorText
                                      : null,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: TextFormField(
                                obscureText: true,
                                controller: passwordController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length < 5) {
                                    return passwordErrorText;
                                  }
                                  return null;
                                },
                                decoration: textInputDecoration.copyWith(
                                  labelText: 'Password',
                                  errorText: showEmailAndPasswordError
                                      ? passwordErrorText
                                      : null,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: TextFormField(
                                controller: userNameController,
                                decoration: textInputDecoration.copyWith(
                                  labelText: 'Name / Alias',
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            Container(
                                height: 50,
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: ElevatedButton(
                                  child: const Text('Sign up'),
                                  onPressed: () async {
                                    setState(() {
                                      showEmailAndPasswordError =
                                          true; // Set the flag to show the error text
                                    });

                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        loading = true;
                                      });
                                      await signUpWithEmailAndPassword();
                                      if (!mounted) return;
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                )),
                            TextButton(
                              child: const Text(
                                'back to sign in',
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () {
                                widget.toggleView();
                              },
                            ),
                            if (_errorText.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  _errorText,
                                  style: Theme.of(context)
                                      .inputDecorationTheme
                                      .errorStyle, // Customize the error text style
                                ),
                              ),
                          ]),
                        ),
                      ),
                    ],
                  )),
            ],
          ));
  }
}
