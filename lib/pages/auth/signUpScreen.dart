import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockniscala/reusable_widgets/reusable_widget.dart';
import 'package:stockniscala/pages/auth/loginScreen.dart';

class signUpScreen extends StatefulWidget {
  const signUpScreen({Key? key}) : super(key: key);

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {

  //controller
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : Container(
        child: Column(
          children: [

            //Username
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 20, top: 20),
              child: TextFormField(
                controller: _userNameTextController,

                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius:
                      BorderRadius.all(Radius.circular(10))),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius:
                      BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.purple,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Username",
                  hintText: 'username anda',
                  labelStyle: TextStyle(color: Colors.purple),
                  // suffixIcon: IconButton(
                  //     onPressed: () {},
                  //     icon: Icon(Icons.close,
                  //         color: Colors.purple))
                ),
              ),
            ),

            //email
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 20, top: 20),
              child: TextFormField(
                controller: _emailTextController,

                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius:
                      BorderRadius.all(Radius.circular(10))),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius:
                      BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.purple,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Email",
                  hintText: 'your-email@domain.com',
                  labelStyle: TextStyle(color: Colors.purple),
                  // suffixIcon: IconButton(
                  //     onPressed: () {},
                  //     icon: Icon(Icons.close,
                  //         color: Colors.purple))
                ),
              ),
            ),

            //pasword
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  controller: _passwordTextController,
                  obscuringCharacter: '*',
                  obscureText: true,
                  decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                        BorderRadius.all(Radius.circular(10))),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                        BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.purple,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Password",
                    hintText: '*********',
                    labelStyle: TextStyle(color: Colors.purple),
                  ),
                  validator: (value) {
                    if (value!.isEmpty && value!.length < 5) {
                      return 'Enter a valid password';
                      {
                        return null;
                      }
                    }
                  },
                ),

            ),
            firebaseUIButton(context, "Sign Up", () {
              FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                  email: _emailTextController.text,
                  password: _passwordTextController.text)
                  .then((value) {
                print("Created New Account");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => loginScreen()));
              }).onError((error, stackTrace) {
                print("Error ${error.toString()}");
              });
            })],
        )

      )
    );
  }
}
