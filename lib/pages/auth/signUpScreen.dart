import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockniscala/reusable_widgets/reusable_widget.dart';
import 'package:stockniscala/pages/auth/loginScreen.dart';
import 'package:stockniscala/utils/color_utils.dart';
import 'package:stockniscala/pages/HomeScreen.dart';

class signUpScreen extends StatefulWidget {
  const signUpScreen({Key? key}) : super(key: key);

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {
  // Controllers
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  bool _isPasswordValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("834200"),
              hexStringToColor("A4550A"),
              hexStringToColor("B5651D"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Email Id",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                ReusablePasswordField(
                  label: "Enter Password (Minimum 9 characters)",
                  icon: Icons.lock_outlined,
                  controller: _passwordTextController,
                  onChanged: (value) {
                    setState(() {
                      _isPasswordValid = value.length >= 9;
                    });
                  },
                ),
                if (!_isPasswordValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Password must be at least 9 characters long.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                firebaseUIButton(context, "Sign Up", () {
                  if (_isPasswordValid) {
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    )
                        .then((value) {
                      print("Created New Account");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => loginScreen(),
                        ),
                      );
                    }).catchError((error) {
                      print("Error ${error.toString()}");
                    });
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
