

import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/shared/constants.dart';
import 'package:flutter/material.dart';

import '../../shared/loading.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  const SignIn({super.key, required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String emailErrorText = "The email can't be empty";
  final String passwordErrorText = 'The password has to be longer than 5 characters';
  String _errorText = '';
  bool loading = false;

  Future<void> signInWithEmailAndPassword() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
    if (result is! User?) {
      setState(() {
        _errorText = result;
      });
    } else {
      _errorText = '';
      print("user signed in successfully");
      print("email: $email, password: $password, userId: $result");
    }
  }

  Future<void> signInAnonymously() async {

    dynamic result = await _auth.signInAnon();
    if (result == null) {
      print("error signing in anonymously");
    } else {
      print("user signed in");
      print(result);
    }
  }

  @override
  Widget build(BuildContext context) {

    bool showEmailAndPasswordError = false;

    return loading ? Loading() : Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            toolbarHeight: 300,
            title: Text("Sign in to Expense"),
            titleTextStyle: appNameTextStyle,
        ),
            body: Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 50),
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
                          hintText: "Email",
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
                          )),
                    ),
                    TextButton(
                      onPressed: () {
                        //forgot password screen
                      },
                      child: const Text(
                        'Forgot Password',
                      ),
                    ),
                    Container(
                        height: 50,
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          child: const Text('Login'),
                          onPressed: () async {
                            setState(() {
                              showEmailAndPasswordError =
                                  true; // Set the flag to show the error text
                            });

                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              await signInWithEmailAndPassword();
                              // add mounted avoid setState() after dispose()
                              if (mounted) {
                                setState(() {
                                  loading = false;
                                });
                              }
                            }
                          },
                        )),
                    if (_errorText.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          _errorText,
                          // style: TextStyle(color: Colors.red),
                          style: Theme.of(context).inputDecorationTheme.errorStyle,// Customize the error text style
                        ),
                      ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('Does not have account?'),
                            TextButton(
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                // go to the sign up screen
                                widget.toggleView();
                              },
                            ),
                          ],
                        ),
                        Text("or"),
                        ElevatedButton(
                          child: Text("Sign in anon"),
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            await signInAnonymously();
                            if (!mounted) return;
                            setState(() {
                              loading = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ]),
                )));
  }
}
