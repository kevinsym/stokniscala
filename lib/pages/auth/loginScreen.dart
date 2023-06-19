import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockniscala/pages/HomeScreen.dart';
import 'package:stockniscala/reusable_widgets/reusable_widget.dart';
import 'package:stockniscala/pages/auth/signUpScreen.dart';
import 'package:stockniscala/pages/auth/resetPassword.dart';
import 'package:stockniscala/utils/color_utils.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _errorTextController = TextEditingController();

  @override
  void dispose() {
    _passwordTextController.dispose();
    _emailTextController.dispose();
    _errorTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("834200"),
              hexStringToColor("A4550A"),
              hexStringToColor("B5651D")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/logo_niscala.png"),
                const SizedBox(height: 30),
                reusableTextField(
                  "Masukkan Email",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 20),
                reusableTextField(
                  "Masukkan Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                  errorTextController: _errorTextController,
                ),
                const SizedBox(height: 5),
                forgetPassword(context),
                firebaseUIButton(
                  context,
                  "Sign In",
                      () {
                    String email = _emailTextController.text.trim();
                    String password = _passwordTextController.text;

                    if (email.isEmpty || password.isEmpty) {
                      _errorTextController.text = 'Please enter email and password.';
                      return;
                    }

                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    )
                        .then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    })
                        .catchError((error) {
                      _errorTextController.text = 'Invalid email or password.';
                    });
                  },
                ),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => signUpScreen()),
            );
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPassword()),
        ),
      ),
    );
  }
}
