import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

import 'auth/loginScreen.dart';
import 'auth/signUpScreen.dart';

class welcomeScreen extends StatefulWidget {
  const welcomeScreen({Key? key}) : super(key: key);

  @override
  State<welcomeScreen> createState() => _welcomeScreenState();
}

class _welcomeScreenState extends State<welcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 20,),
              Image.asset(
                "assets/logo_niscala.png",
                height: 300,
                width: 600,
              ),
              Text(
                'Selamat Datang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              Expanded(
                flex: 0,
                child: Text(
                  'Silahkan login untuk melanjutkan',
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w300,
                      // height: 1.5,
                      fontSize: 15),
                ),
              ),
              SizedBox(
                height: 135,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      backgroundColor: Colors.brown,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 3.3,
                          vertical: 20)
                    // padding: EdgeInsets.only(
                    //     left: 120, right: 120, top: 20, bottom: 20),
                  ),
                  onPressed: () {
                    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftPop, child: loginScreen(), childCurrent: welcomeScreen()));
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => loginScreen()));
                  },
                  child: Text(
                    'Lanjutkan!',
                    style: TextStyle(fontSize: 17),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum memiliki akun?',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  signUpScreen()));
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.brown, fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}