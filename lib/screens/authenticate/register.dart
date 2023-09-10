
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String emailErrorText = "The email can't be empty";
  final String passwordErrorText =
      'The password has to be longer than 5 characters';
  String _errorText = '';
  bool loading = false;

  Future<void> signUpWithEmailAndPassword() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    dynamic result = await _auth.registerWithEmailAndPassword(email, password);
    if (result is! User?) {
      setState(() {
        _errorText = result;
      });
    } else {
      _errorText = '';
      print("user signed up and logged in successfully");
      print("email: $email, password: $password, userId: $result");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showEmailAndPasswordError = false;

    return loading ? Loading() : Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: const Text("Register"),
          titleTextStyle: appNameTextStyle,
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Form(
              key: _formKey,
              child: ListView(children: <Widget>[
                const SizedBox(height: 100),
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
                      errorText:
                      showEmailAndPasswordError ? emailErrorText : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 5) {
                        return passwordErrorText;
                      }
                      return null;
                    },
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Password',
                      errorText:
                      showEmailAndPasswordError ? passwordErrorText : null,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Sign up'),
                      onPressed: () async {
                        setState(() {
                          showEmailAndPasswordError =
                          true; // Set the flag to show the error text
                        });

                        if (_formKey.currentState!.validate()) {
                          setState(() {loading = true;});
                          await signUpWithEmailAndPassword();
                          if (!mounted) return;
                          setState(() {loading = false;});
                        }
                      },
                    )),
                if (_errorText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      _errorText,
                      style: Theme.of(context).inputDecorationTheme.errorStyle, // Customize the error text style
                    ),
                  ),
              ]),
            )));
  }
}
